#!/bin/bash
#  __     __                          _     ____             _                                                     ___  ____  
#  \ \   / /_ _  __ _ _ __ __ _ _ __ | |_  |  _ \  ___   ___| | _____ _ __    ___  _ __    _ __ ___   __ _  ___   / _ \/ ___| 
#   \ \ / / _` |/ _` | '__/ _` | '_ \| __| | | | |/ _ \ / __| |/ / _ \ '__|  / _ \| '_ \  | '_ ` _ \ / _` |/ __| | | | \___ \ 
#    \ V / (_| | (_| | | | (_| | | | | |_  | |_| | (_) | (__|   <  __/ |    | (_) | | | | | | | | | | (_| | (__  | |_| |___) |
#     \_/ \__,_|\__, |_|  \__,_|_| |_|\__| |____/ \___/ \___|_|\_\___|_|     \___/|_| |_| |_| |_| |_|\__,_|\___|  \___/|____/ 
#               |___/                                                                                                         
#
# As of 2021-10-23  ...things keep changing
# used this post to get started: https://dhwaneetbhatt.com/blog/run-docker-without-docker-desktop-on-macos
#
# More about vagrant: https://learn.hashicorp.com/collections/vagrant/getting-started
#
# If you have used Docker Desktop before you may have get an error message like "exec: "docker-credential-desktop.exe": executable file not found"
# Follow these instructions to fix: https://stackoverflow.com/questions/65896681/exec-docker-credential-desktop-exe-executable-file-not-found-in-path-using

##
## Global Settings
##
VM_IP_ADDRESS=192.168.66.4
DOCKER_PORT=2375

##
## Install required packages via Homebrew
##

# Install VirtualBox
brew install --cask virtualbox
brew install --cask virtualbox-extension-pack

# Install Vagrant and the vbguest plugin to manage VirtualBox Guest Additions on the VM
brew install vagrant
vagrant plugin install vagrant-vbguest

# Install Docker CLI
brew install docker
brew install docker-compose

mkdir -p vagrant-docker-engine
pushd vagrant-docker-engine

cat << EOF > Vagrantfile
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/focal64'
  config.vm.hostname = 'docker.local'
  config.vm.network 'private_network', ip: '${VM_IP_ADDRESS}'
  config.vm.network 'forwarded_port', guest: ${DOCKER_PORT}, host: ${DOCKER_PORT}, id: 'dockerd'
  config.vm.provider 'virtualbox' do |vb|
    vb.name = 'ubuntu-docker'
    vb.memory = '2048'
    vb.cpus = '2'
  end
  config.vm.provision 'shell', path: 'provision.sh'
  
  # Configuration for Port Forwarding
  # Uncomment or add new ones here as required
  # config.vm.network 'forwarded_port', guest: 6379, host: 6379, id: 'redis'
  # config.vm.network 'forwarded_port', guest: 3306, host: 3306, id: 'mysql'
end
EOF

cat <<EOF > provision.sh
# Install Docker
apt-get remove docker docker.io containerd runc
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release net-tools software-properties-common
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] <https://download.docker.com/linux/ubuntu> focal stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker docker.io containerd

echo "Configure Docker to listen on a TCP socket"
if [ ! -d /etc/systemd/system/docker.service.d ]; then
    mkdir -p /etc/systemd/system/docker.service.d
fi
echo '[Service]'                                                                > /etc/systemd/system/docker.service.d/docker.conf
echo 'ExecStart='                                                              >> /etc/systemd/system/docker.service.d/docker.conf
echo 'ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock' >> /etc/systemd/system/docker.service.d/docker.conf

mkdir -p /etc/docker
echo '{  "hosts": ["fd://", "tcp://0.0.0.0:${DOCKER_PORT}"] }' > /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker.service
EOF
chmod +x provision.sh

echo "Starting virtual machine..."
vagrant up

popd


cat << EOF
Installation is completed!

Add this definition to your \`.profile\`
\`\`\`
export DOCKER_HOST=tcp://127.0.0.1:${DOCKER_PORT}
\`\`\`

Try 
\`\`\`
DOCKER_HOST=tcp://127.0.0.1:${DOCKER_PORT} docker run hello-world
\`\`\`

Suspend virtual machine with
\`\`\`
vagrant suspend
\`\`\`

EOF