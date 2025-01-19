// Method to safely restart the Jenkins controller with a 1-minute timeout
def safeRestartWithTimeout() {

    if (!Jenkins.instance.isQuietingDown()) {


        println "Putting Jenkins into quiet mode (allowing jobs to finish)..."
        Jenkins.instance.doQuietDown()


        def timeoutInMillis = 60 * 1000 // 1 minute in milliseconds
        def waitInterval = 5000 // Check every 5 seconds
        def elapsedTime = 0

        println "Waiting up to 1 minute for all jobs to finish before restarting..."
        while (elapsedTime < timeoutInMillis) {
            
            if (Jenkins.instance.computers.every { it.countBusy() == 0 } && Jenkins.instance.getQueue().isEmpty()) {
                println "All jobs finished, restarting Jenkins now..."
                Jenkins.instance.restart()
                return "Restart initiated successfully."
            }

            sleep(waitInterval)
            elapsedTime += waitInterval
        }

        println "Timeout reached. Restarting Jenkins now, even if jobs are still running..."
        Jenkins.instance.restart()
        return "Restart initiated after timeout."
    } else {
        println "Jenkins is already in quiet mode."
        Jenkins.instance.restart()
        return "Restart initiated."
    }
}

safeRestartWithTimeout()