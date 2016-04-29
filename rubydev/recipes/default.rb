#
# Cookbook Name:: rubydev
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'nginx::default'
include_recipe 'rvm::system'
