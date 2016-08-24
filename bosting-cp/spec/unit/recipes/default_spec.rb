#
# Cookbook Name:: bosting-cp
# Spec:: default
#
# Copyright (c) 2016 Alexander Zubkov, All Rights Reserved.

require 'spec_helper'

describe 'bosting-cp::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
