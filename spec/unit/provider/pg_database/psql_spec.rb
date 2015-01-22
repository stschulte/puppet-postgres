#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:pg_database).provider(:psql) do

  before :each do
    described_class.stubs(:command).with(:psql).returns '/foo/psql'
    described_class.stubs(:command).with(:createdb).returns '/foo/createdb'
    described_class.stubs(:command).with(:dropdb).returns '/foo/dropdb'
  end

  let :provider do
    described_class.new(
      :name     => 'puppetdb',
      :ensure   => :present,
      :owner    => 'puppetdbuser',
      :encoding => 'UTF8',
      :collate  => 'C',
      :ctype    => 'en_US.UTF-8'
    )
  end

  describe "instance" do
    it "should return instances from simple list output" do
      described_class.expects(:execute).with(%w{/foo/psql --no-password --no-align --tuples-only --list}, :failonfail => true, :combine => true, :uid => 'postgres').returns File.read(my_fixture('simple'))
      instances = described_class.instances
      expect(instances.size).to eq 1
      expect(instances[0].name).to eq('postgres')
      expect(instances[0].owner).to eq('postgres')
      expect(instances[0].encoding).to eq('UTF8')
      expect(instances[0].collate).to eq('de_DE.utf8')
      expect(instances[0].ctype).to eq('de_DE.utf8')
    end

    it "should return instances from list output with newlines" do
      described_class.expects(:execute).with(%w{/foo/psql --no-password --no-align --tuples-only --list}, :failonfail => true, :combine => true, :uid => 'postgres').returns File.read(my_fixture('newline'))
      instances = described_class.instances
      expect(instances.size).to eq(3)
      expect(instances[0].name).to eq('postgres')
      expect(instances[0].owner).to eq('postgres')
      expect(instances[0].encoding).to eq('UTF8')
      expect(instances[0].collate).to eq('de_DE.utf8')
      expect(instances[0].ctype).to eq('de_DE.utf8')

      expect(instances[1].name).to eq('template0')
      expect(instances[1].owner).to eq('postgres')
      expect(instances[1].encoding).to eq('UTF8')
      expect(instances[1].collate).to eq('en_US.utf8')
      expect(instances[1].ctype).to eq('C')

      expect(instances[2].name).to eq('template1')
      expect(instances[2].owner).to eq('postgres')
      expect(instances[2].encoding).to eq('UTF8')
      expect(instances[2].collate).to eq('de_DE.utf8')
      expect(instances[2].ctype).to eq('de_DE.utf8')
    end
  end

  describe "when managing ensure" do
    describe "exists?" do
      it "should return true when the resource is present" do
        provider.set(:ensure => :present)
        expect(provider).to be_exists
      end

      it "should return false when the resource is absent" do
        provider.set(:ensure => :absent)
        expect(provider).to_not be_exists
      end
    end

    describe "create" do
      it "should use createdb to create a database" do
        Puppet::Type.type(:pg_database).new(:name => 'puppetdb', :provider => provider)
        provider.expects(:execute).with(%w{/foo/createdb --no-password puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass owner if specified" do
        Puppet::Type.type(:pg_database).new(:name => 'puppetdb', :owner => 'puppetdbuser', :provider => provider)
        provider.expects(:execute).with(%w{/foo/createdb --no-password --owner=puppetdbuser puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass encoding if specified" do
        Puppet::Type.type(:pg_database).new(:name => 'puppetdb', :encoding => 'UTF8', :provider => provider)
        provider.expects(:execute).with(%w{/foo/createdb --no-password --encoding=UTF8 puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass collate if specified" do
        Puppet::Type.type(:pg_database).new(:name => 'puppetdb', :collate => 'C', :provider => provider)
        provider.expects(:execute).with(%w{/foo/createdb --no-password --lc-collate=C puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass ctype if specified" do
        Puppet::Type.type(:pg_database).new(:name => 'puppetdb', :ctype => 'en_US.UTF-8', :provider => provider)
        provider.expects(:execute).with(%w{/foo/createdb --no-password --lc-ctype=en_US.UTF-8 puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass every specified argument" do
        Puppet::Type.type(:pg_database).new(
          :name     => 'puppetdb',
          :owner    => 'puppetdbuser',
          :encoding => 'UTF8',
          :collate  => 'C',
          :ctype    => 'en_US.UTF-8',
          :provider => provider
        )
        provider.expects(:execute).with(%w{/foo/createdb --no-password --encoding=UTF8 --lc-collate=C --lc-ctype=en_US.UTF-8 --owner=puppetdbuser puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end
    end

    describe "destroy" do
      it "should execute dropdb to drop the database" do
        Puppet::Type.type(:pg_database).new(:name => 'puppetdb', :provider => provider)
        provider.expects(:execute).with(%w{/foo/dropdb --no-password puppetdb}, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.destroy
      end
    end
  end

  {
    :owner    => 'puppetdbuser',
    :encoding => 'UTF8',
    :collate  => 'C',
    :ctype    => 'en_US.UTF-8'
  }.each_pair do |property, should_value|
    describe "when managing #{property}" do
      it "should return the cached value" do
        expect(provider.send(property)).to eq(should_value)
      end

      it "should raise an error when changing #{property}" do
        expect { provider.send("#{property}=".intern, 'C') }.to raise_error Puppet::Error, /not supported/
      end
    end
  end
end
