require 'serverspec'
require 'net/ssh'

set :backend, :ssh

set :host, 'localhost'
set :ssh_options, :user => 'vagrant', :password=> 'vagrant',:port => 2222


#set :ssh_options, :user => 'root', :keys => '/Users/johndesp/.ec3/default.pem',:port => 22