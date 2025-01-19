# Android App: My First App

This repository contains the code for **My First Android App**, designed and built using **Android Studio** with **Kotlin**. The project integrates **GitHub Actions** for automated builds, follows the **Gitflow workflow**, and uses a **Telegram bot** to publish release artifacts to a Telegram group.

## Features

- Simple and user-friendly Android app built with Kotlin.
- Automated build pipeline using GitHub Actions.
- Gitflow workflow for efficient branch management.
- Release artifacts published to a Telegram group via a Telegram bot.

## Requirements

- **Android Studio** (latest version recommended)
- **Kotlin** (version included in Android Studio)
- **Git**
- **GitHub account**
- **Telegram Bot Token** (see [Telegram Bot Documentation](https://core.telegram.org/bots))
- **Telegram Chat ID** for the group/channel to publish artifacts

## Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:brenneran/android-app.git
   cd android-app
   ```

2. Open the project in Android Studio.

3. Sync the Gradle files and ensure all dependencies are installed.

4. Build and run the app on an emulator or a physical device.

## Gitflow Workflow

This project follows the **Gitflow workflow**:

- **`main` branch**: Contains the production-ready code.
- **`develop` branch**: Contains the latest development changes.
- **Feature branches**: For developing individual features.
- **Release branches**: For preparing production releases.
- **Hotfix branches**: For quick fixes in the production code.

## GitHub Actions

The repository includes a pre-configured GitHub Actions workflow:

- Triggers on pushes to the `develop` and `release/*` branches.
- Builds the app using Gradle.
- Generates an APK artifact.
- Publishes the APK to a Telegram group.

### Workflow Configuration

- Add the following secrets to your GitHub repository:
  - `TELEGRAM_BOT_TOKEN`: The token of your Telegram bot.
  - `TELEGRAM_CHAT_ID`: The chat ID of the Telegram group.

## Usage

1. Create a new feature branch for your development:
   ```bash
   git checkout -b feature/your-feature
   ```

2. Commit your changes and push to the repository:
   ```bash
   git add .
   git commit -m "Add new feature"
   git push origin feature/your-feature
   ```

3. Merge the feature branch into `develop` once the feature is complete.

4. For releases, create a release branch and follow the workflow:
   ```bash
   git checkout -b release/v1.0.0
   git push origin release/v1.0.0
   ```

5. GitHub Actions will automatically build and publish the release APK to the Telegram group.


## Contact

For any inquiries, feel free to reach out:
- **Email**: andrey@brenner.space