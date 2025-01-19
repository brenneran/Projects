# Packer Installation for Developer Machine of Image

This repository contains a Bitbucket pipeline script for creating a Packer image based on `official-windows2022-base-1-*` with all the necessary tools required for the developer machine of the Scanner image.

## Tools Installed

The following tools are installed as part of this Packer image:

- Python x64 2.7, 3.6.3, and 3.7.9
- Git version 2.33.0.2
- Notepad++
- 7zip
- Git LFS (Large File Storage) version 2.7.2
- Pandoc version 2.9.2.1
- MobaXterm
- Python 3.9
- .NET Framework 4.8.1 Developer Pack
- Yarn
- AWS CLI
- NuGet CommandLine version 3.4.4
- .NET version 6.0.3
- Conan package manager
- OpenJDK (latest version)
- Visual Studio 2022 and Visual Studio 2017 (configured via a config file)
- Concurrency Visualizer for Visual Studio 2017 (VSIX)
- CadentProjectsTemplates (VSIX)
- Intel Compiler 2023 and 2022 (2022 with integration to VS2017 and 2023 with integration to VS2022)
- PowerShell version 7.4.0
- Installation and registration of Amazon CloudHSM
- Adding certificate to Root CA
- Enabling Wireless-Networking
- Creating a task for lunchjnlp.bat
- Adding required Bamboo variables
- Stopping Windows Update services
- Installing .NET SDK installer 6.0.321
- Enabling the Force AutoLogon feature in Windows using Autologon.exe
- Enabling Windows File download in Internet Explorer
- Specifying the path to uuidgen.exe and signtool.exe
- Installing donetFrostingo
- Copying Buildcert's to D:\Buildcert
- Installing SSH Agent and starting it
- Adding a private key to ssh-agent
- Cloning repo to D:\repo
- Installing InstallShield2020R3StandaloneBuild
- Configuring NuGet

## Usage

To use this Packer image, follow these steps:

1. Create CloudBees pipeline with: REPO_URL
2. Script patch: win-ami-build/Jenkinsfile.groovy
4. Once the pipeline configuration is completed successfully, the Packer image will be available for use.

## Notes

- Ensure that you have necessary permissions and cre.ds configured to access the required tools and repositories during the Packer image creation process.
- If there is not version of installed software or tool,  that's mean the tool installed using Chocolatey as latest version at the time of the packer build.
- Review and update the tool versions or configurations as needed for your specific requirements.
- This readme file provides an overview of the installed tools and the usage of this Packer image. For detailed information on each tool's configuration or usage, refer to their respective documentation.
