#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:pg_database) do

  it "should have name as its keyattribute" do
    expect(described_class.key_attributes).to eq([ :name ])
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure, :owner, :encoding, :collate, :ctype].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe "when validating values" do
    describe "for ensure" do
      it "should allow present" do
        expect(described_class.new(:name => 'foo', :ensure => 'present')[:ensure]).to eq(:present)
      end

      it "should allow absent" do
        expect(described_class.new(:name => 'foo', :ensure => 'absent')[:ensure]).to eq(:absent)
      end

      it "should not allow something else" do
        expect { described_class.new(:name => 'foo', :ensure => 'foo') }.to raise_error Puppet::Error, /Invalid value/
      end
    end

    describe "for owner" do
      it "should allow a simple owner name" do
        expect(described_class.new(:name => 'foo', :owner => 'puppetdb')[:owner]).to eq('puppetdb')
      end
    end

    describe "for encoding" do
      it "should allow LATIN1" do
        expect(described_class.new(:name => 'foo', :encoding => 'LATIN1')[:encoding]).to eq(:LATIN1)
      end

      it "should allow LATIN9" do
        expect(described_class.new(:name => 'foo', :encoding => 'LATIN9')[:encoding]).to eq(:LATIN9)
      end

      it "should allow UTF8" do
        expect(described_class.new(:name => 'foo', :encoding => 'UTF8')[:encoding]).to eq(:UTF8)
      end

      it "should not allow anything else" do
        expect { described_class.new(:name => 'foo', :encoding => 'ANSII') }.to raise_error Puppet::Error, /Invalid value/
      end
    end

    describe "for collate" do
      it "should allow a C locale" do
        expect(described_class.new(:name => 'foo', :collate => 'C')[:collate]).to eq('C')
      end

      it "should allow a valid locale" do
        expect(described_class.new(:name => 'foo', :collate => 'en_US.utf8')[:collate]).to eq('en_US.utf8')
      end
    end

    describe "for ctype" do
      it "should allow a C locale" do
        expect(described_class.new(:name => 'foo', :ctype => 'C')[:ctype]).to eq('C')
      end

      it "should allow a valid locale" do
        expect(described_class.new(:name => 'foo', :ctype => 'en_US.utf8')[:ctype]).to eq('en_US.utf8')
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
        expect(pg_database.autorequire).to be_empty
      end

      it "should autorequire a matching pg_role" do
        catalog.add_resource pg_database
        catalog.add_resource pg_role

        reqs = pg_database.autorequire
        expect(reqs.size).to eq(1)
        expect(reqs[0].source).to eq(pg_role)
        expect(reqs[0].target).to eq(pg_database)
      end
    end
  end
end
