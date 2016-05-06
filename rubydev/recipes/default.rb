#
# Cookbook Name:: rubydev
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Avoid "No package kernel-devel available."
# http://qiita.com/Ikumi/items/9f8d02d088de669762a7
case node[:platform]
  when 'centos', 'redhat'
    package 'kernel-devel' do
      action :install
      options '--enablerepo=C6.4-base,C6.4-updates'
    end
end

include_recipe 'phantomjs::default'

include_recipe 'rvm::system'
include_recipe 'nodejs::default'

include_recipe 'nginx::default'
