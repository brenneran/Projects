#!/bin/bash

# Define the path to the deployment file
WORKFLOW_DIR=".github/workflows"
DEPLOYMENT_FILE="$WORKFLOW_DIR/android.yml"
mkdir -p "$WORKFLOW_DIR"

cat <<EOF > "$DEPLOYMENT_FILE"
name: Release Build Pipeline

on:
  push:
    branches:
      - 'release/*'

jobs:
  setup-env:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: 17

      - name: Setup Android SDK
        uses: android-actions/setup-android@v2.0.10

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v3

  decode-keystore:
    runs-on: ubuntu-latest
    needs: setup-env  # Ensure this job runs after 'setup-env'

    steps:
      - name: Checking out branch
        uses: actions/checkout@v3  # Ensure the repo is checked out in this job as well

      - name: Decode Keystore
        env:
          ENCODED_STRING: \${{ secrets.KEYSTORE_BASE_64 }}
          RELEASE_KEYSTORE_PASSWORD: \${{ secrets.RELEASE_KEYSTORE_PASSWORD }}
          RELEASE_KEYSTORE_ALIAS: \${{ secrets.RELEASE_KEYSTORE_ALIAS }}
          RELEASE_KEY_PASSWORD: \${{ secrets.RELEASE_KEY_PASSWORD }}
        run: |
          echo \$ENCODED_STRING > keystore-b64.txt
          base64 -d keystore-b64.txt > keystore.jks

  build:
    runs-on: ubuntu-latest
    needs: decode-keystore

    outputs:
      versionName: \${{ steps.getVersion.outputs.versionName }}
      apkfile: \${{ steps.renameApk.outputs.apkfile }}

    steps:
      - name: Checking out branch
        uses: actions/checkout@v3

      - name: Fetch Git tags
        run: git tag 1.0.2

      - name: Get versionCode and versionName
        id: getVersion
        run: |
          VERSION_NAME=\$(./gradlew -q androidGitVersion | grep name | cut -d' ' -f2)
          
          # Sanitize versionName by removing unwanted characters
          VERSION_NAME=\$(echo "\$VERSION_NAME" | tr -d '\t\n\r')  # Remove tab, newline, and carriage return
          
          # Ensure that only the version part (e.g., 1.0.1-dirty) is used
          VERSION_NAME=\$(echo "\$VERSION_NAME" | sed 's/^[^0-9]*//')  # Strip out any prefix text like androidGitVersion.name
          echo "::set-output name=versionName::\$VERSION_NAME"
        shell: bash

      - name: Build Release apk
        env:
          RELEASE_KEYSTORE_PASSWORD: \${{ secrets.RELEASE_KEYSTORE_PASSWORD }}
          RELEASE_KEYSTORE_ALIAS: \${{ secrets.RELEASE_KEYSTORE_ALIAS }}
          RELEASE_KEY_PASSWORD: \${{ secrets.RELEASE_KEY_PASSWORD }}
        run: ./gradlew assembleRelease --stacktrace

      - name: Rename APK
        id: renameApk
        run: |
          APK_PATH="app/build/outputs/apk/release/app-release.apk"
          VERSION_NAME="\${{ steps.getVersion.outputs.versionName }}"
          NEW_APK_NAME="FinGrowth-\$VERSION_NAME.apk"
          mkdir -p ./release-builds
          mv "\$APK_PATH" "./release-builds/\$NEW_APK_NAME"
          echo "::set-output name=apkfile::./release-builds/\$NEW_APK_NAME"
        shell: bash

      - name: Upload APK as artifact
        uses: actions/upload-artifact@v3
        with:
          name: release-apk-\${{ steps.getVersion.outputs.versionName }}
          path: ./release-builds/FinGrowth-\${{ steps.getVersion.outputs.versionName }}.apk

  deploy:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Download APK artifact
        uses: actions/download-artifact@v3
        with:
          name: release-apk-\${{ needs.build.outputs.versionName }}
          path: ./release-builds

      - name: Check APK file path
        run: |
          echo "Checking for APK file..."
          ls -l ./release-builds

      - name: Send the APK to Telegram
        env:
          APK_PATH: ./release-builds/FinGrowth-\${{ needs.build.outputs.versionName }}.apk
          BOT_API_KEY: \${{ secrets.BOT_API_KEY }}
          CHAT_ID: \${{ secrets.CHAT_ID }}
        run: |
          if [ -f "\$APK_PATH" ]; then
            echo "Sending APK: \$APK_PATH"
            curl -F chat_id=\$CHAT_ID -F document=@"\$APK_PATH" -F caption="Template-\$(date +"%Y%m%d-%H%M")" https://api.telegram.org/bot\${BOT_API_KEY}/sendDocument
          else
            echo "Error: APK file not found at \$APK_PATH"
            exit 1
          fi
EOF

echo "deployment file created at $DEPLOYMENT_FILE"