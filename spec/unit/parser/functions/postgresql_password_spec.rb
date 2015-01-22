#! /usr/bin/env ruby

require 'spec_helper'

describe "postgresql_password", :type => :puppet_function do

  it "should return the salted hash" do
    expect(subject.call(["postgres", "foobar"])).to eq('md5d5d2b7621f9dfa5d09376c9c966bf109')
    expect(subject.call(["puppetdbuser", "puppetdb"])).to eq('md5f73f3746cf0e20f69818d85e3908e7e3')
  end

end
