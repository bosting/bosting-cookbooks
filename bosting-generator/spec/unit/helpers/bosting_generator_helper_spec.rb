require_relative '../../../libraries/bosting_generator_helper'
require 'mocha'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.mock_with :mocha
end

describe BostingGenerator::Helper do
  describe 'read_array_from_rc_conf' do
    let(:test_class) { Class.new { extend BostingGenerator::Helper } }

    it 'should load empty list if file not found' do
      ::File.stubs(:readlines).raises(Errno::ENOENT)
      test_class.read_array_from_rc_conf('some_list').should == []
    end

    it 'should load empty list if array not found' do
      ::File.stubs(:readlines).returns(['first line', 'second line'])
      test_class.read_array_from_rc_conf('some_list').should == []
    end

    it 'should load an empty list' do
      ::File.stubs(:readlines).returns(['some_list=""'])
      test_class.read_array_from_rc_conf('some_list').should == []
    end

    it 'should load one element list' do
      ::File.stubs(:readlines).returns(['some_list="one"'])
      test_class.read_array_from_rc_conf('some_list').should == ['one']
    end

    it 'should load two element list' do
      ::File.stubs(:readlines).returns(['some_list="one two"'])
      test_class.read_array_from_rc_conf('some_list').should == ['one', 'two']
    end

    it 'should load from the last line' do
      ::File.stubs(:readlines).returns(['some_list="one two three"', 'some_list="one two"'])
      test_class.read_array_from_rc_conf('some_list').should == ['one', 'two']
    end
  end
end
