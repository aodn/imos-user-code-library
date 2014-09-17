# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box_url = "http://grahamc.com/vagrant/ubuntu-12.04-omnibus-chef.box"
  config.vm.box = "ubuntu-12.04-omnibus-chef.box"

  config.ssh.forward_x11 = true

  config.vm.provision :chef_solo do |chef|

    chef.add_recipe "apt::default"
    chef.add_recipe "python"
    chef.add_recipe "imos_python"
    chef.add_recipe "r"

  end
end
