// List of plugin IDs to disable and uninstall for controllers
def pluginIds = [
    "blueocean-autofavorite",
    "blueocean-bitbucket-pipeline",
    "blueocean",
    "blueocean-core-js",
    "blueocean-pipeline-editor",
    "cloudbees-blueocean-default-theme",
    "blueocean-commons",
    "blueocean-config",
    "blueocean-dashboard",
    "jenkins-design-language",
    "blueocean-display-url",
    "blueocean-events",
    "blueocean-git-pipeline",
    "blueocean-github-pipeline",
    "blueocean-i18n",
    "blueocean-jwt",
    "blueocean-personalization",
    "blueocean-pipeline-api-impl",
    "blueocean-pipeline-scm-api",
    "blueocean-rest",
    "blueocean-rest-impl",
    "blueocean-web",
    "bootstrap4-api",
  	"popper2-api",
  	"popper-api",
  	"workflow-cps-global-lib",
  	"workflow-aggregator-plugin"
]

// Method to disable plugins
def disablePlugins(pluginIds) {
    pluginIds.each { pluginId ->
        def plugin = Jenkins.getInstance().getPluginManager().getPlugin(pluginId)
        
        // Check if the plugin exists
        if (plugin) {
            // Disable the plugin
            plugin.disable()
            println "Plugin '${pluginId}' disabled"
        } else {
            println "Plugin '${pluginId}' not found"
        }
    }
}

// Method to uninstall plugins
def uninstallPlugins(pluginIds) {
    pluginIds.each { pluginId ->
        def plugin = Jenkins.getInstance().getPluginManager().getPlugin(pluginId)
        
        // Check if the plugin exists
        if (plugin) {
            // Uninstall the plugin
            plugin.doDoUninstall()
            println "Plugin '${pluginId}' uninstalled"
        } else {
            println "Plugin '${pluginId}' not found"
        }
    }
}

// Step 1: Disable all plugins
println "Disabling all plugins..."
disablePlugins(pluginIds)

println "All plugins disabled. Proceeding to uninstallation..."

// Step 2: Uninstall all plugins after they are disabled
uninstallPlugins(pluginIds)

// Step 3: Retry - Disable and uninstall again
println "Retrying to disable and uninstall plugins..."
disablePlugins(pluginIds)

println "Retry uninstallation..."
uninstallPlugins(pluginIds)

return "All plugins disabled and uninstalled successfully (with retry)"