#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:pg_database) do

  it "should have name as its keyattribute" do
    described_class.key_attributes.should == [ :name ]
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end

    [:ensure, :owner, :encoding, :collate, :ctype].each do |property|
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

    describe "for owner" do
      it "should allow a simple owner name" do
        described_class.new(:name => 'foo', :owner => 'puppetdb')[:owner].should == 'puppetdb'
      end
    end

    describe "for encoding" do
      it "should allow LATIN1" do
        described_class.new(:name => 'foo', :encoding => 'LATIN1')[:encoding].should == :LATIN1
      end

      it "should allow LATIN9" do
        described_class.new(:name => 'foo', :encoding => 'LATIN9')[:encoding].should == :LATIN9
      end

      it "should allow UTF8" do
        described_class.new(:name => 'foo', :encoding => 'UTF8')[:encoding].should == :UTF8
      end

      it "should not allow anything else" do
        expect { described_class.new(:name => 'foo', :encoding => 'ANSII') }.to raise_error Puppet::Error, /Invalid value/
      end
    end

    describe "for collate" do
      it "should allow a C locale" do
        described_class.new(:name => 'foo', :collate => 'C')[:collate].should == 'C'
      end

      it "should allow a valid locale" do
        described_class.new(:name => 'foo', :collate => 'en_US.utf8')[:collate].should == 'en_US.utf8'
      end
    end

    describe "for ctype" do
      it "should allow a C locale" do
        described_class.new(:name => 'foo', :ctype => 'C')[:ctype].should == 'C'
      end

      it "should allow a valid locale" do
        described_class.new(:name => 'foo', :ctype => 'en_US.utf8')[:ctype].should == 'en_US.utf8'
      end
    end
  end

  describe "autorequire" do

    let :pg_role do
      Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :ensure => :present)
    end

    let :pg_database do
      described_class.new(:name => 'puppetdb', :owner => 'puppetdbuser')
    end

    let :catalog do
      Puppet::Resource::Catalog.new
    end

    describe "pg_role" do
      it "should not autorequire a pg_role if none found" do
        catalog.add_resource pg_database
        pg_database.autorequire.should be_empty
      end

      it "should autorequire a matching pg_role" do
        catalog.add_resource pg_database
        catalog.add_resource pg_role

        reqs = pg_database.autorequire
        reqs.size.should == 1
        reqs[0].source.must == pg_role
        reqs[0].target.must == pg_database
      end
    end
  end
end
