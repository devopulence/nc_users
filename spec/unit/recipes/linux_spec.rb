require 'chefspec'
require_relative '../../spec_helper'
require 'chef-vault'


describe 'nc_users::default' do


  context 'if the platform_family is rhel' do

    let(:chef_run) do

      ChefSpec::ServerRunner.new do |node, server|
        node.automatic['platform'] = 'redhat'
        node.automatic['platform_family'] = 'rhel'
        node.automatic['hostname'] = 'TRSTLPRTSTAPV99'

        server.create_data_bag('nc_user', {
            'item_1' => {
                'username' => 'abc123'
            },
            'item_2' => {
                'username' => 'def456'
            }
        })

        server.create_data_bag('dj_user', {
            'item_1' => {
                'username' => 'johndesp'
            },
            'item_2' => {
                'username' => 'jaclyn'
            }
        })



      end.converge(described_recipe)
    end

    it 'includes the nc_secureos::default recipe' do
      expect(chef_run).to include_recipe('nc_users::default')
    end


  end

end



