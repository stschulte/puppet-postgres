#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:pg_role) do

  it "should have name as its keyattribute" do
    described_class.key_attributes.should == [ :name ]
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end

    [:ensure, :password, :superuser, :createdb, :createrole, :inherit, :login].each do |property|
      it "should have a #{property} property" do
        described_class.attrtype(property).should == :property
      end
    end
  end

  describe "when validating values" do
    describe "for ensure" do
      it "should allow present" do
        described_class.new(:name => 'foo', :ensure => 'present')[:ensure].should == :present
      end

      it "should allow absent" do
        described_class.new(:name => 'foo', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not allow something else" do
        expect { described_class.new(:name => 'foo', :ensure => 'foo') }.to raise_error Puppet::Error, /Invalid value/
      end
    end

    describe "password" do
      it "should allow an encrypted password" do
      end

      it "should not allow an unencrypted password" do
      end
    end

    [:superuser, :createdb, :createrole, :inherit, :login].each do |bool_property|
      describe bool_property do
        it "should allow true" do
          described_class.new(:name => 'puppetdbuser', bool_property => true)[bool_property].should == true
        end

        it "should alias \"true\" to true" do
          described_class.new(:name => 'puppetdbuser', bool_property => 'true')[bool_property].should == true
        end

        it "should alias \"yes\" to true" do
          described_class.new(:name => 'puppetdbuser', bool_property => 'yes')[bool_property].should == true
        end

        it "should allow false" do
          described_class.new(:name => 'puppetdbuser', bool_property => false)[bool_property].should == false
        end

        it "should alias \"false\" to false" do
          described_class.new(:name => 'puppetdbuser', bool_property => 'false')[bool_property].should == false
        end

        it "should alias \"no\" to false" do
          described_class.new(:name => 'puppetdbuser', bool_property => 'no')[bool_property].should == false
        end

        it "should not allow anything else" do
          expect { described_class.new(:name => 'puppetdbuser', bool_property => 'yess') }.to raise_error Puppet::Error, /expected a boolean value/
        end
      end
    end
  end
end
