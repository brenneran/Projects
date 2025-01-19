@Library("my-shared-lib")
import groovy.json.JsonSlurperClassic

//replaceme is what you need to replace

pipeline {
    agent { label 'linux-ami-main-build' }
    parameters {
        booleanParam(name: 'TESTING', defaultValue: false, description: 'Enable testing for IDO project')
    }

    environment {
        BITBUCKET_API_BASE_URL = 'https://YOUR_URL_HERE/rest/api/1.0/projects'
        RESPONSE_FILE_RTH = 'rth_branch_response.json'
        RESPONSE_FILE_NG = 'ng_branch_response.json'
    }

    stages {
        stage('Initialize Repos') {
            steps {
                script {
                    env.LATEST_RELEASE_PREFIX_RTH = params.TESTING ? 'rel/SubModule-' : 'release/SubModule-'
                    env.LATEST_RELEASE_PREFIX_NG = params.TESTING ? 'rel/' : 'release/'
                    env.RTH_REPO = params.TESTING ? 'submodule-test' : 'submodule'
                    env.NG_REPO = params.TESTING ? 'ng-test' : 'ng'
                    env.RELEASE = params.TESTING ? 'rel' : 'release'
                    DISABLE_STAGE = 'true'
                }
            }
        }

        stage('Fetch Last Three Branches of NG Repo') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'username', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        def authString = "${USER}:${PASSWORD}".getBytes('iso-8859-1').encodeBase64().toString()
                        def ngRepoUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'yourproject'}/repos/${env.NG_REPO}/branches"
                        def response = httpRequest(
                            url: "${ngRepoUrl}?limit=100",
                            customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                            acceptType: 'APPLICATION_JSON',
                            consoleLogResponseBody: true
                        )
        
                        def jsonResponse = new JsonSlurperClassic().parseText(response.content)
                        def relBranches = jsonResponse?.values?.findAll { 
                            it.displayId.startsWith(env.LATEST_RELEASE_PREFIX_NG) 
                        } ?: []
        
                        if (relBranches.isEmpty()) {
                            error "No branches found starting with '${env.LATEST_RELEASE_PREFIX_NG}'."
                        }
        
                        echo "Found branches: ${relBranches.collect { it.displayId }}"
                        def branchMap = [:]
        
                        relBranches.each { branch ->
                            try {
                                def versionParts = branch.displayId.replace(env.LATEST_RELEASE_PREFIX_NG, '').split('_').collect { it.toInteger() }
                                def versionNumber = versionParts.join('').toInteger()
                                branchMap[versionNumber] = branch.displayId
                            } catch (Exception e) {
                                echo "Skipping invalid branch: ${branch.displayId}. Error: ${e.message}"
                            }
                        }
                        if (branchMap.isEmpty()) {
                            error "No valid branches found after filtering and converting to numbers."
                        }
                        echo "Constructed branch map: ${branchMap}"
                        def sortedKeys = branchMap.keySet().sort()
                        def lastThreeBranches = sortedKeys.takeRight(3).collect { key -> branchMap[key] }
                        echo "Last three branches: ${lastThreeBranches}"
                        env.LAST_THREE_BRANCHES = lastThreeBranches.join(',')
                    }
                }
            }
        }

        stage('Pull replacemeRTH branch from Combo Var file') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-username', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        def authString = "${USER}:${PASSWORD}".getBytes('iso-8859-1').encodeBase64().toString()
                        def branchToreplacemeRTHMap = [:]
                        env.LAST_THREE_BRANCHES.split(',').each { ngBranch ->
                            echo "Fetching combo_variables_input.txt for branch: ${ngBranch}"
                            def fileUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.NG_REPO}/raw/combo_variables_input.txt?at=${ngBranch}"
                            def fileResponse = httpRequest(
                                url: fileUrl,
                                customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                acceptType: 'TEXT_PLAIN',
                                consoleLogResponseBody: true
                            )
                            def comboVariables = fileResponse.content.split("\n") // Split into lines
                            def rthSubmoduleLine = comboVariables.find { it.trim().startsWith("rth_submodule=") } // Find the line with "rth_submodule="
                            if (rthSubmoduleLine) {
                                def version = rthSubmoduleLine.replace("rth_submodule=", "").trim() // Extract the version
                                branchToreplacemeRTHMap[ngBranch] = "${env.RELEASE}/replacemeRTH-${version}"
                                echo "Mapped NG branch '${ngBranch}' to replacemeRTH branch: ${env.RELEASE}/replacemeRTH-${version}"
                            } else {
                                echo "No rth_submodule version found in combo_variables_input.txt for branch ${ngBranch}"
                            }
                        }
                        env.BRANCH_TO_replacemeRTH_MAP = new groovy.json.JsonBuilder(branchToreplacemeRTHMap).toString()
                        echo "Branch to replacemeRTH map: ${branchToreplacemeRTHMap}"
                        env.TARGET_BRANCHES = branchToreplacemeRTHMap.values().join(',')
                        echo "TARGET_BRANCHES set to: ${env.TARGET_BRANCHES}"
                    }
                }
            }
        }

        stage('Fetch Submodule Commit of replacemeRTH for NG Branches') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-username', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        def authString = "${USER}:${PASSWORD}".getBytes('iso-8859-1').encodeBase64().toString()
                        def lastThreeBranches = env.LAST_THREE_BRANCHES.split(',')
                        lastThreeBranches.each { ngBranch ->
                            echo "Fetching submodule commit for replacemeRTH in NG branch: ${ngBranch}"
                            def submoduleCommitUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.NG_REPO}/browse?at=${ngBranch}&path=replacemeRTH"
                            def submoduleResponse = httpRequest(
                                url: submoduleCommitUrl,
                                customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                acceptType: 'APPLICATION_JSON',
                                consoleLogResponseBody: true
                            )
                            def submoduleJson = new JsonSlurperClassic().parseText(submoduleResponse.content)
                            def replacemeRTHEntry = submoduleJson.children.values.find {
                                it.path.components == ['replacemeRTH'] && it.type == 'SUBMODULE'
                            }
        
                            if (replacemeRTHEntry) {
                                def submoduleCommitHash = replacemeRTHEntry.contentId
                                echo "replacemeRTH submodule commit for NG branch ${ngBranch}: ${submoduleCommitHash}"s
                                env."COMMIT_HASH_${ngBranch}" = submoduleCommitHash
                            } else {
                                echo "No replacemeRTH submodule entry found for NG branch ${ngBranch}"
                            }
                        }
                    }
                }
            }
        }

        stage('Pull the TAG and Last Commit of replacemeRTH') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-username', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        def authString = "${USER}:${PASSWORD}".getBytes('iso-8859-1').encodeBase64().toString()
        
                        // Ensure TARGET_BRANCHES is defined
                        if (!env.TARGET_BRANCHES) {
                            error("TARGET_BRANCHES is not defined. Ensure the previous stage sets this environment variable.")
                        }
        
                        def targetBranches = env.TARGET_BRANCHES.split(',') // Split branches into a list
                        echo "Processing the following branches: ${targetBranches.join(', ')}"
        
                        def branchBaseUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.RTH_REPO}/branches"
                        def tagUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.RTH_REPO}/tags"
                        
                        targetBranches.each { branchName ->
                            echo "Fetching details for branch: ${branchName}"
        
                            // Fetch the latest commit for the branch
                            def branchUrl = "${branchBaseUrl}?filterText=${branchName}&limit=1"
                            def branchResponse = httpRequest(
                                url: branchUrl,
                                customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                acceptType: 'APPLICATION_JSON',
                                consoleLogResponseBody: true
                            )
        
                            def branchJson = new JsonSlurperClassic().parseText(branchResponse.content)
        
                            if (!branchJson.values || branchJson.values.isEmpty()) {
                                echo "Branch ${branchName} not found or has no data."
                                return
                            }
        
                            def branchDetails = branchJson.values[0]
                            def latestCommit = branchDetails.latestCommit
                            echo "Branch: ${branchName}, Latest Commit: ${latestCommit}"
        
                            env.LATEST_BRANCH = branchName
                            env.LATEST_BRANCH_COMMIT = latestCommit
        
                            // Fetch tags associated with this commit
                            def start = 0
                            def matchingTags = []
                            def isLastPage = false
        
                            while (!isLastPage) {
                                def paginatedUrl = "${tagUrl}?filterText=replacemeRTH-&limit=25&start=${start}"
                                def tagResponse = httpRequest(
                                    url: paginatedUrl,
                                    customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                    acceptType: 'APPLICATION_JSON',
                                    consoleLogResponseBody: true
                                )
        
                                def tagJson = new JsonSlurperClassic().parseText(tagResponse.content)
                                echo "Tag JSON structure: ${tagJson.values}"
        
                                // Filter tags by those associated with the specified commit
                                matchingTags += tagJson.values.findAll { it.latestCommit == latestCommit }
        
                                // Update pagination controls
                                isLastPage = tagJson.isLastPage
                                start = tagJson.nextPageStart
                            }
        
                            if (matchingTags.isEmpty()) {
                                def email = "a.brenner@aligntech.com"
                                emailext(
                                    subject: "Attention Required: Missing Tag Details for ${branchName}",
                                    body: """
                                    <html>
                                        <body style="font-family: Tahoma; font-size: 14px; text-align: left;">
                                            <p>The last commit <b>${latestCommit}</b> of branch <b>${branchName}</b> in the repository <b>${env.RTH_REPO}</b> has no tag,</p>
                                            <p>or the tag does not contain the latest commit. Please investigate.</p>
                                        </body>
                                    </html>
                                    """,
                                    mimeType: 'text/html',
                                    to: email
                                )
                                error("No matching tags found for branch ${branchName} in repo ${env.RTH_REPO} with commit ${latestCommit}. Sending message to ${email}")
                            } else {
                                // Assume the latest tag (sorted or highest in list) if needed
                                def latestTag = matchingTags[-1]
                                env.LATEST_TAG = latestTag.displayId
                                env.LATEST_TAG_COMMIT = latestTag.latestCommit
                                echo "Branch: ${branchName}, Latest Commit: ${latestCommit}, Latest Tag: ${env.LATEST_TAG}"
                            }
                        }
                    }
                }
            }
        }

        stage('Verify and Determine Next Action') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-username', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        def authString = "${USER}:${PASSWORD}".getBytes('iso-8859-1').encodeBase64().toString()
                        def updateMap = [:]
                        def updateRequired = false

                        env.LAST_THREE_BRANCHES.split(',').each { ngBranch ->
                            echo "Processing NG branch: ${ngBranch}"

                            def submoduleCommit = env."COMMIT_HASH_${ngBranch}"
                            if (!submoduleCommit) {
                                echo "No submodule commit found for NG branch: ${ngBranch}. Skipping."
                                return
                            }

                            def replacemeRTHBranch = new JsonSlurperClassic().parseText(env.BRANCH_TO_replacemeRTH_MAP)[ngBranch]
                            if (!replacemeRTHBranch) {
                                echo "No replacemeRTH branch mapping found for NG branch: ${ngBranch}. Skipping."
                                return
                            }

                            def branchUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.RTH_REPO}/branches?filterText=${replacemeRTHBranch}&limit=1"
                            def branchResponse = httpRequest(
                                url: branchUrl,
                                customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                acceptType: 'APPLICATION_JSON'
                            )

                            def branchDetails = new JsonSlurperClassic().parseText(branchResponse.content)?.values ?: []
                            if (branchDetails.isEmpty()) {
                                echo "Branch ${replacemeRTHBranch} not found. Skipping."
                                return
                            }

                            def latestCommit = branchDetails[0]?.latestCommit
                            if (!latestCommit) {
                                echo "No latest commit found for branch: ${replacemeRTHBranch}. Skipping update check for ${ngBranch}."
                                return
                            }

                            updateMap[ngBranch] = (submoduleCommit != latestCommit)
                            if (updateMap[ngBranch]) updateRequired = true
                        }

                        env.UPDATE_SUBMODULE = updateRequired.toString()
                        env.UPDATE_MAP = new groovy.json.JsonBuilder(updateMap).toString()
                        echo "UPDATE_MAP: ${env.UPDATE_MAP}"
                    }
                }
            }
        }
        
        stage('Prepare BRANCH_TAG_MAP') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-username', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        def authString = "${USER}:${PASSWORD}".getBytes('iso-8859-1').encodeBase64().toString()
                        def branchTagMap = [:]
                        def targetBranches = env.LAST_THREE_BRANCHES.split(',')
        
                        targetBranches.each { ngBranch ->
                            echo "Processing NG branch: ${ngBranch}"
        
                            // Map NG branch to its corresponding replacemeRTH branch
                            def replacemeRTHBranch = new JsonSlurperClassic().parseText(env.BRANCH_TO_replacemeRTH_MAP)[ngBranch]
                            if (!replacemeRTHBranch) {
                                echo "No replacemeRTH branch mapping found for NG branch: ${ngBranch}. Skipping."
                                return
                            }
                            
                            // Fetch the last commit of the mapped replacemeRTH branch
                            def branchBaseUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.RTH_REPO}/branches"
                            def branchUrl = "${branchBaseUrl}?filterText=${replacemeRTHBranch}&limit=1"
                            
                            def branchResponse = httpRequest(
                                url: branchUrl,
                                customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                acceptType: 'APPLICATION_JSON'
                            )
                            
                            def branchJson = new JsonSlurperClassic().parseText(branchResponse.content)
                            if (!branchJson.values || branchJson.values.isEmpty()) {
                                echo "No details found for branch: ${replacemeRTHBranch}. Skipping."
                                return
                            }
        
                            def latestCommit = branchJson.values[0].latestCommit
                            echo "Latest commit for branch ${replacemeRTHBranch}: ${latestCommit}"
        
                            // Fetch tags for the latest commit
                            def tagUrl = "${BITBUCKET_API_BASE_URL}/${params.TESTING ? 'ido' : 'replaceme'}/repos/${env.RTH_REPO}/tags"
                            def matchingTags = []
                            def start = 0
                            def isLastPage = false
        
                            while (!isLastPage) {
                                def paginatedUrl = "${tagUrl}?filterText=replacemeRTH-&limit=25&start=${start}"
                                def tagResponse = httpRequest(
                                    url: paginatedUrl,
                                    customHeaders: [[name: 'Authorization', value: "Basic ${authString}"]],
                                    acceptType: 'APPLICATION_JSON'
                                )
        
                                def tagJson = new JsonSlurperClassic().parseText(tagResponse.content)
                                if (!tagJson.values || tagJson.values.isEmpty()) {
                                    echo "No tags found for commit: ${latestCommit}. Skipping."
                                    break
                                }
        
                                matchingTags += tagJson.values.findAll { it.latestCommit == latestCommit }
        
                                isLastPage = tagJson.isLastPage
                                start = tagJson.nextPageStart
                            }
        
                            if (matchingTags.isEmpty()) {
                                echo "No tags found for the latest commit of branch: ${replacemeRTHBranch}. Proceeding without a tag."
                            } else {
                                def latestTag = matchingTags[-1] // Assume the last tag is the most relevant
                                echo "Latest tag for ${replacemeRTHBranch}: ${latestTag.displayId}"
                                branchTagMap[ngBranch] = latestTag.displayId
                            }
                        }
        
                        if (branchTagMap.isEmpty()) {
                            error("No tags found for any branches. Please check the repository configuration.")
                        }
        
                        env.BRANCH_TAG_MAP = new groovy.json.JsonBuilder(branchTagMap).toString()
                        echo "BRANCH_TAG_MAP: ${env.BRANCH_TAG_MAP}"
                    }
                }
            }
        }

        stage('Update Submodule and Combo Variable') {
            steps {
                script {
                    def updateMap = new JsonSlurperClassic().parseText(env.UPDATE_MAP)
                    def branchTagMap = new JsonSlurperClassic().parseText(env.BRANCH_TAG_MAP)
                    def branchToreplacemeMap = new JsonSlurperClassic().parseText(env.BRANCH_TO_replacemeRTH_MAP)
        
                    env.LAST_THREE_BRANCHES.split(',').each { ngBranch ->
                        if (updateMap[ngBranch]) {
                            def tagVersion = branchTagMap[ngBranch]?.replace("replacemeRTH-", "")
                            if (!tagVersion) {
                                echo "No tag version found for ${ngBranch}. Skipping update."
                                return
                            }

                            def replacemeRTHBranch = branchToreplacemeMap[ngBranch]
                            if (!replacemeRTHBranch) {
                                echo "No mapped replacemeRTH branch for NG branch: ${ngBranch}. Skipping update."
                                return
                            }
        
                            sshagent(credentials: ['your-username-ssh']) {
                                sh """
                                    # Clone NG repository
                                    rm -rf ${env.WORKSPACE}/${env.BUILD_TAG}/${env.NG_REPO}
                                    mkdir -p ${env.WORKSPACE}/${env.BUILD_TAG}
                                    cd ${env.WORKSPACE}/${env.BUILD_TAG}
                                    git clone --branch ${ngBranch} --single-branch ssh://git@src.aligntech.com/${params.TESTING ? 'ido' : 'replaceme'}/${env.NG_REPO}.git
                                    cd ${env.NG_REPO}
                                    
                                    # Update submodule
                                    git submodule update --init replacemeRTH
                                    cd replacemeRTH
                                    git fetch origin ${replacemeRTHBranch}
                                    git checkout FETCH_HEAD
                                    cd ..
                                    git add replacemeRTH
                                    git commit -m "Update replacemeRTH submodule to branch ${replacemeRTHBranch}"
                                    
                                    # Update combo_variables.txt
                                    echo "rth_submodule=${tagVersion}" > combo_variables.txt
                                    git add combo_variables.txt
                                    git commit -m "Update rth_submodule with tag ${tagVersion}"
                                    
                                    # Push changes
                                    git push origin ${ngBranch}
                                """
                            }
                            echo "Updated NG branch: ${ngBranch} with tag: ${tagVersion} and submodule pointing to branch: ${replacemeRTHBranch}."
                        } else {
                            echo "No update required for NG branch: ${ngBranch}."
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
