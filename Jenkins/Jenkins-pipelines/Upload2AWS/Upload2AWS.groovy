def retryCounts = [:]

pipeline {
    agent { label 'linux' }

    environment {
        S3_JSON = '{AWS_S3_URL.example.json}'
    }

    stages {
        stage('Checkout and Parse JSON') {
            steps {
                script {
                    // Checkout and parse JSON
                    withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh '''
                            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                            aws configure set region us-west-2
                            aws s3 cp --quiet "$S3_JSON" json_data.json
                        '''
                    }

                    // Read JSON from file
                    def json = readJSON file: 'json_data.json'

                    // Process BucketBasePaths
                    json.BucketBasePaths.each { key, value ->
                        if (!value.ShouldUpload) {
                            echo "Skipping ${key} upload because BucketBasePaths.ShouldUpload is false"
                            return // Skip this iteration
                        }
                        def basePath = value.basePath
                        env."${key}BasePath" = basePath
                        echo "BasePath for ${key}: ${basePath}"
                    }

                    // Filter files to upload
                    env.filesToUpload = groovy.json.JsonOutput.toJson(json.FilesToUpload.findAll { it.ShouldUpload })
                    env.bucketBasePaths = groovy.json.JsonOutput.toJson(json.BucketBasePaths)
                }
            }
        }

        stage('Download Files and Upload') {
            steps {
                script {
                    // Step 1: Parse files to upload and bucket base paths from environment variables
                    def filesToUpload = readJSON text: env.filesToUpload
                    def bucketBasePaths = readJSON text: env.bucketBasePaths
                    def hasChinaKey = bucketBasePaths.containsKey('China')

                    // Step 2: Process each file to download from FullSourcePath
                    retry(3) {
                        filesToUpload.each { file ->
                            def sourcePath = file.FullSourcePath
                            def fileName = sourcePath.tokenize('/').last()

                            try {
                                withCredentials([usernamePassword(credentialsId: 'aws_up_creds', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                                    sh "curl -s -u $USER:$PASSWORD -o ${fileName} ${sourcePath}"
                                }

                                // Step 3: Calculate MD5 hash for downloaded file
                                def md5Hash = sh(script: "md5sum ${fileName} | awk '{ print \$1 }'", returnStdout: true).trim()
                                echo "MD5 Hash for ${file.Name}: ${md5Hash}"
                                echo '==================Separator after the Download from the FullSourcePath step================='

                                // Step 4: Upload to AWS S3 of each Bucket
                                def destinationKey = file.destination.replaceAll(/\/[^\/]+$/, '')
                                bucketBasePaths.each { bucket ->
                                    if (!bucket.value.ShouldUpload) {
                                        echo "Skipping upload because ShouldUpload for ${bucket.key} is false"
                                        return // Skip this iteration
                                    }

                                    def basePath = bucket.value.basePath
                                    def bucketName = extractBucketName(basePath)

                                    if (!bucketName) {
                                        error "Bucket name not found for ${fileName}"
                                    }

                                    // Step 5: Uploading file to AWS S3 bucket
                                    echo "Extracted S3 Bucket name for ${fileName} of ${file.Name}: ${bucketName}"
                                    withCredentials([usernamePassword(credentialsId: (hasChinaKey && bucket.key == 'China') ? 'aws-credentials-china' : 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                                        def endpoint = (hasChinaKey && bucket.key == 'China') ? '--endpoint-url https://s3.cn-north-1.amazonaws.com.cn --region cn-north-1' : '--region us-west-2'
                                        sh """
                                            aws s3api put-object --bucket '${bucketName}' --key '${destinationKey}/${fileName}' --output json --body '${fileName}' ${endpoint} > upload_result.json
                                        """
                                    }

                                    // Step 6: Download the file from each Bucket
                                    def downloadedFileName = (hasChinaKey && bucket.key == 'China') ? "${fileName}_downloaded_cn" : "${fileName}_downloaded_global"
                                    withCredentials([usernamePassword(credentialsId: (hasChinaKey && bucket.key == 'China') ? 'aws-credentials-china' : 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                                        def endpoint = (hasChinaKey && bucket.key == 'China') ? '--endpoint-url https://s3.cn-north-1.amazonaws.com.cn --region cn-north-1' : '--region us-west-2'
                                        sh """
                                            aws s3 cp s3://${bucketName}/${destinationKey}/${fileName} ${downloadedFileName} ${endpoint}
                                        """
                                    }

                                    // Step 7: Compare MD5 hash of each downloaded file
                                    def downloadedMd5Hash = sh(script: "md5sum ${downloadedFileName} | awk '{ print \$1 }'", returnStdout: true).trim()
                                    echo "MD5 Hash for downloaded ${downloadedFileName}: ${downloadedMd5Hash}"

                                    // Compare MD5 hashes
                                    if (md5Hash != downloadedMd5Hash) {
                                        throw new Exception("MD5 hash mismatch for ${file.Name}")
                                    } else {
                                        echo "MD5 hash verified for ${file.Name}"
                                        echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                                    }
                                }
                            } catch (Exception e) {
                                echo "Error in processing ${fileName}: ${e.message}"
                                retryCounts[fileName] = retryCounts.containsKey(fileName) ? retryCounts[fileName] + 1 : 1
                                throw e // Rethrow to trigger the retry block
                            }
                        }
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Clean up
                    deleteDir()
                }
            }
        }
    }

    post {
        always {
            script {
                // Print retry counts if there were retries
                if (retryCounts.isEmpty()) {
                    echo 'No retries were attempted.'
                } else {
                    echo 'Retry counts:'
                    retryCounts.each { fileName, count ->
                        echo "${fileName}: ${count} retries"
                    }
                }
            }
        }
    }
}

// Function to extract bucket name from basePath
def extractBucketName(basePath) {
    def matcher = (basePath =~ /https:\/\/(.+)\.s3\./)
    return matcher ? matcher[0][1] : null
}