# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  end

  config.vbguest.auto_update = false

  # OS
  config.vm.box = "centos6.5"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"

  #ssh
  config.ssh.insert_key = false

  # Networking
  config.vm.hostname = "rubydev"
  config.vm.network :private_network, ip: "192.168.33.10"

  # Source Folder
  config.vm.synced_folder "./", "/share", \
      create: true, owner: "vagrant", group: "vagrant", \
      mount_options: ["dmode=777,fmode=777"]

  # Chef
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = ["./", "./berks-cookbooks"]
    chef.add_recipe "vim::default"
    chef.add_recipe "rubydev::default"
    chef.add_recipe "rubydev::mysql"

    chef.json = {
      rvm: {
        user: "root",
        default_ruby: "ruby-2.1",
        user_default_ruby: "ruby-2.1",
        rubies: ["ruby-2.1"]
      },
      mysql: {
        user: "rubydev",
        password: "rubydev",
        database: "rubydev"
      }
    }

  end

end
