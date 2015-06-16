#
# Cookbook Name:: nc_local_users
# Resource:: default
#
# Copyright 2013, News Corp
#
# All rights reserved - Do Not Redistribute
#

# Depending on the state attribute inside the data bag
# state => [active, inactive, locked, nologin ]
# 			:active 	=> Make sure it has a valid shell and is unlocked.
# 			:inactive 	=> Apply all the restrictions. (Same like: :locked :nologin)
# 			:locked 	=> The password will be locked.
# 			:nologin 	=> The shell will be override to /sbin/nologin.
actions :active, :inactive, :locked , :nologin, :remove

attribute :username, 	:kind_of => String,				:name_attribute => true, :required => true
attribute :password, 	:kind_of => String, 			:default => "*"
attribute :uid, 		:kind_of => [String,Integer]
attribute :gid, 		:kind_of => [String,Integer]
attribute :comment, 	:kind_of => String
attribute :home, 		:kind_of => String
attribute :shell, 		:kind_of => String, 			:default => "/bin/bash"
attribute :system_user, :equal_to => [true, false],		:default => false		
attribute :group_name, 	:kind_of => String,				:default => nil
attribute :groups, 		:kind_of => [Array,String], 	:default => nil
attribute :ssh_keys, 	:kind_of => [Array,String], 	:default => []
attribute :sudo, 		:equal_to => [true, false],		:default => false


def initialize(*args)
  super
  @action = :active
end
