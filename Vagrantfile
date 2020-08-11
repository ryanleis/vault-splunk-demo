# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provision "shell", inline: <<-SHELL
  apt-get update
  apt-get -y install zip unzip
  apt-get -y install curl
  apt-get -y install jq
  SHELL

  config.vm.define "splunk" do|config|
    config.vm.box = "hashicorp/bionic64"
    config.vm.box_version = "1.0.282"

    config.vm.hostname = "splunk"

    config.vm.network "private_network", ip: "192.168.200.10"

    config.vm.provision "shell",
      path: "scripts/setupSplunk.sh"

    config.vm.provision "shell",
      path: "scripts/configureSplunk.sh"

  end

  config.vm.define "vault" do |config|

    config.vm.box = "hashicorp/bionic64"
    config.vm.box_version = "1.0.282"

    config.vm.hostname = "vault"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
    config.vm.network "private_network", ip: "192.168.100.10"

    config.vm.provision "shell",
      path: "scripts/setupVaultServer.sh",
      env: {'RAFT_NODE' => "Vault"}

    config.vm.provision "shell",
      path: "scripts/initAndUnsealVault.sh"

    config.vm.provision "shell",
      path: "scripts/setupMonitorAgent.sh"

    config.vm.provision "shell",
      path: "scripts/configureVault.sh"

  end

end
