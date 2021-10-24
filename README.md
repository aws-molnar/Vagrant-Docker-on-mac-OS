# Vagrant Docker on mac OS
...as of 2021-10-23  ...things keep changing

*Installation script to run Docker on mac OS, using Homebrew, Vagrant and VirtualBox*

This implementation is based on this post https://dhwaneetbhatt.com/blog/run-docker-without-docker-desktop-on-macos

More about vagrant: https://learn.hashicorp.com/collections/vagrant/getting-started

If you have used Docker Desktop before you may have get an error message like "exec: "docker-credential-desktop.exe": executable file not found"
Follow these instructions to fix: https://stackoverflow.com/questions/65896681/exec-docker-credential-desktop-exe-executable-file-not-found-in-path-using

## Instructions
1. Install Homebrew from https://brew.sh/ if you havn't already
2. Download the `install.sh` script, review and customize
3. Run `install.sh` from the terminal

## What does it do?
The install script performs the following steps:
1. install required packages for mac OS, including VirtualBox, Vagrant, and Docker
2. create `Vagrant` and `provision.sh` configuration files in the folder `vagrant-docker-engine`
3. install and start-up virtual machine (the VM will be running, suspend with `vagrant suspend`)

## Clean-up
In order to clean up
1. Run the commands `vagrant halt` and `vagrant destroy`
2. Use the command `brew uninstall` to uninstall the repsective Homebrew packages.
 
