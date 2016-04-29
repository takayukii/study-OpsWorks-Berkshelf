#
# Cookbook Name:: rubydev
# Recipe:: mysql
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

mysql_service 'default' do
  version '5.6'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password 'password'
  action [:create, :start]
end

mysql_client 'default' do
  action :create
end

mysql_database = node[:mysql][:database]
mysql_user = node[:mysql][:user]
mysql_password = node[:mysql][:password]

bash "prepare database" do
  code "mysql -h 127.0.0.1 -P 3306 -u root -ppassword -e 'create database #{mysql_database} default charset utf8;'"
  not_if "mysql -h 127.0.0.1 -P 3306 -u root -ppassword -e 'show databases;' | grep #{mysql_database}"
end

grant_statement = "GRANT ALL PRIVILEGES ON *.* TO '#{mysql_user}'@'%' IDENTIFIED BY '#{mysql_password}' WITH GRANT OPTION;"
grant_statement += "GRANT ALL PRIVILEGES ON *.* TO '#{mysql_user}'@'localhost' IDENTIFIED BY '#{mysql_password}' WITH GRANT OPTION;"

sql_statement = "SELECT User FROM mysql.user WHERE User = '#{mysql_user}';"

bash "prepare user" do
  code "mysql -h 127.0.0.1 -P 3306 -u root -ppassword -e \"#{grant_statement}\""
  not_if "mysql -h 127.0.0.1 -P 3306 -u root -ppassword -e \"#{sql_statement}\" | grep #{mysql_user}"
end
