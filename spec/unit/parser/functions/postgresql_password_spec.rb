#! /usr/bin/env ruby

require 'spec_helper'

describe "postgresql_password", :type => :puppet_function do

  it "should return the salted hash" do
    subject.call(["postgres", "foobar"]).should == 'md5d5d2b7621f9dfa5d09376c9c966bf109'
    subject.call(["puppetdbuser", "puppetdb"]).should == 'md5f73f3746cf0e20f69818d85e3908e7e3'
  end

end
