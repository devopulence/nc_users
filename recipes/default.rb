#
# Cookbook Name:: nixtest
# Recipe:: default
#
# Copyright 2014, Techout
#
# All rights reserved - Do Not Redistribute
#

require 'chef/data_bag'

include_recipe 'chef-vault'

if node['news_corp']['vaults']
  node['news_corp']['vaults'].each do |vaultname, vaulthash|
    puts("vault name  #{vaultname}")
    log 'Joette'
    Chef::Log.info("Cheflog-The value for action is : '#{vaulthash['action']}'")
    puts("The value for action is : '#{vaulthash['action']}'")
    vaulthash.each do |key, value|
      puts("key = #{key} and value = #{value}")


    end

    ################### Start ##################
    # The default attribute file contains a default attribute called ['nc_users']['databag']
    db_name = vaultname


#include_recipe 'do_vaulttest::createtemplate'


    puts("databag name from ['nc_users']['databag'] in default attribute file is #{db_name}")

    db = data_bag(db_name) # gets a handle to the databag


# The following is from chef_vault

    db.each do |i| # i is the item name, databag can have multiple items , multiple json files -


      puts("db item name is  #{i}")

      begin

        if /_keys/ !~ "#{i}"
          the_item = chef_vault_item(db_name, "#{i}")

          nc_users the_item["username"] do
            Chef::Log.info("The keys is: '#{the_item['ssh_keys']}'")
            %w{username password uid gid comment home shell group_name
					    	groups ssh_keys sudo }.each do |attr|
              send(attr, the_item[attr]) if the_item[attr]
              Chef::Log.info("The '#{attr}' is: '#{the_item[attr]}'")
            end
            action :active
          end


        end #end if

      rescue Chef::Exceptions::ValidationFailed => e
        log e.message
        log 'Validation Failed Error with Databag Item - indicates that Data Bag Item not encrypted for this node'
      rescue ChefVault::Exceptions::KeysNotFound => e
        log e.message
        log 'Keys Not Found Error with Databag Item'
      rescue ArgumentError => e
        log e.message
        log 'Error with Databag Item - indicates a data bag item exists that is not properly created for this nc_users cookbook'


      end

      # !~ /dog/
      # username = the_item["username"]
      # password = the_item["password"]
      # Chef::Log.info("The '#{i}' username in loop is: '#{username}'")
      # Chef::Log.info("The '#{i}' password in loop  is: '#{password}'")


    end


    #################### End ################


  end
end rescue NoMethodError



