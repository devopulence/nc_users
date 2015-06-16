#
# Cookbook Name:: nc_local_users
# Provider:: default
#
# Copyright 2015, News Corp
#
# All rights reserved - Do Not Redistribute
#

def whyrun_supported?
  true
end

def load_current_resource
  @home       = new_resource.home || "#{node[:nc_secure_home][:home_path]}/#{new_resource.username}"
  @shell      = new_resource.shell || node[:nc_local_users][:d_shell]
  @comment    = new_resource.comment || "Account: #{new_resource.username}"
  @password   = non_passwd(new_resource.password)
  @group_name = new_resource.group_name || new_resource.username
  @gid        = new_resource.gid
  @uid        = new_resource.uid
end

action :active do
  # After :create/:maintain the user make sure it is unlocked
  do_user   [ :create, :unlock ]
  do_groups :create
  do_dir    :create
  do_keys   :create
  do_sudoer :create
end

action :inactive do 
  # We may do both :locked & :nologin
  # Override shell and proceed
  @shell = "/sbin/nologin"

  # Before :lock the user make sure it exist
  do_user   [ :create, :lock ]
  do_groups :create
  do_dir    :create
  do_keys   :create
end

action :locked do
  # Before :lock the user make sure it exist
  do_user   [:create, :lock] 
  do_groups :create
  do_dir    :create
  do_keys   :create  
end

action :nologin do
  # Override shell and proceed
  @shell = "/sbin/nologin"

  do_user   [:create]
  do_groups :create
  do_dir    :create
end

action :remove do
  # Delete the user and all other stuff
  do_user [:remove]
end

private 

def non_passwd(pwd)
  case pwd
    when '*','',nil,'x' then false
    else pwd
  end
end

def do_user(exec_action)
  # avoid variable scoping issues in resource block
  home, shell, comment, password, gid, uid = @home, @shell, @comment, @password, @gid,  @uid
  
  # Does the group already exist? modify or create?
  `grep ^#{@group_name} /etc/group|cut -d: -f1`.strip == @group_name ? g_action = :modify : g_action = :create

  # If we have an specific group lets first create it
  r = group @group_name do
    gid     gid.to_i  if gid
    system  new_resource.system_user
    action  :nothing
    not_if  "awk -F: '{print $3}' /etc/group |grep -w #{gid}"
  end
  r.run_action(g_action) if exec_action != :remove && gid
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  
  # If the group is already there please use that gid
  gid = `grep ^#{@group_name} /etc/group|cut -d: -f3`.strip if g_action == :modify

  # Create and maintain the user
  r = user new_resource.username do
    comment   comment   if comment
    uid       uid.to_i  if uid
    gid       gid.to_i  if gid
    home      home      if home
    shell     shell     if shell
    password  password  if password
    system    new_resource.system_user
    supports  :mananc_home => node[:nc_local_users][:manage_home], :non_unique => node[:nc_local_users][:non_unique]
    action    :nothing
  end

  exec_action.each do  |action|
    begin
      r.run_action(action)
    rescue 
      Chef::Log.fatal("Provider::Default Couldn't execute action :#{action} to #{@new_resource} in the do_user definition")
      if action == :remove && node[:nc_local_users][:force_delete]
        Chef::Log.info("Provider::Default Forcing Removal of #{new_resource.username}")
        execute "Force User Delete" do
          command "userdel -fr #{new_resource.username}"
          user    "root"
        end
      end
    end
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
end

def do_dir(exec_action)
  unless new_resource.system_user
    ["#{@home}/.ssh", @home].each do |dir|
      r = directory dir do
        owner       new_resource.username
        group       Etc.getpwnam(new_resource.username).gid
        mode        dir =~ %r{/\.ssh$} ? '0700' : '0700' #'1700' #
        recursive   true
        action      :nothing
      end
      
      r.run_action(exec_action)
      new_resource.updated_by_last_action(true) if r.updated_by_last_action?
    end
  end
end

def do_keys(exec_action)
  unless new_resource.system_user
    # Avoid variable scoping issues in resource block
    ssh_keys = Array(new_resource.ssh_keys)

    r = template "#{@home}/.ssh/authorized_keys" do
      source      'authorized_keys.erb'
      owner       new_resource.username
      group       Etc.getpwnam(new_resource.username).gid
      mode        '0600'
      variables   :user     => new_resource.username,
                  :ssh_keys => ssh_keys,
                  :fqdn     => node['fqdn']
      action      :nothing
    end
    r.run_action(exec_action)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
end

def do_groups(exec_action)
  unless new_resource.groups.nil?
    # Avoid variable scoping issues in resource block
    groups = Array(new_resource.groups)

    groups.each do |g_name|
        r = group g_name do
          members new_resource.username
          append  true
          action  :nothing
        end
        r.run_action(exec_action)
        new_resource.updated_by_last_action(true) if r.updated_by_last_action?
    end
  end
end

def do_sudoer(exec_action)
  unless new_resource.sudo.nil?
    if new_resource.sudo 
      # Add the user as a sudoer member
      rc = Chef::Util::FileEdit.new("/etc/sudoers")
      rc.insert_line_if_no_match(/^#{new_resource.username}/,"#{new_resource.username} ALL=(ALL) NOPASSWD:ALL")
      rc.write_file
    else
      # Remove the user as a sudoer member
      rc = Chef::Util::FileEdit.new("/etc/sudoers")
      rc.search_file_delete_line(/#{new_resource.username}/)
      rc.write_file
    end
  end 
end
