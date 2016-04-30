#
# Cookbook Name:: rubydev
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'rvm::system'
include_recipe 'nodejs::default'

include_recipe 'nginx::default'