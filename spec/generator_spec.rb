require 'spec_helper'

describe Generator do
  it 'should exist' do
    lambda { Generator.new }.should_not raise_error
  end

  describe "initialization" do
    it 'should randomly init itself with 200 random names' do
      Generator.should_receive(:random_name).exactly(200).times.and_return('foobar')
      g = Generator.new
      g.current_generation.size.should == 200
    end
  end

  describe "random_name" do
    it 'should default to 7 letters' do
      a = Generator.random_name.size.should == 7
    end

    it 'should allow different sizes' do
      Generator.random_name(a = rand(255)).size.should == a
    end
  end
end
