#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:pg_role) do

  it "should have name as its keyattribute" do
    expect(described_class.key_attributes).to eq([ :name ])
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure, :password, :superuser, :createdb, :createrole, :inherit, :login].each do |property|
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

    describe "password" do
      it "should allow an encrypted password" do
        expect(described_class.new(:name => 'foo', :password => 'md559faa421729e846dd800dce59943bfc1')[:password]).to eq('md559faa421729e846dd800dce59943bfc1')
      end

      it "should not allow an unencrypted password" do
        expect { described_class.new(:name => 'foo', :password => 'plain_text') }.to raise_error Puppet::Error, /plain text is invalid/
      end

      it "should allow absent to clear a password" do
        expect(described_class.new(:name => 'foo', :password => 'absent')[:password]).to eq(:absent)
      end
    end

    [:superuser, :createdb, :createrole, :inherit, :login].each do |bool_property|
      describe bool_property.to_s do
        it "should allow true" do
          expect(described_class.new(:name => 'puppetdbuser', bool_property => true)[bool_property]).to eq(:true)
        end

        it "should alias \"true\" to :true" do
          expect(described_class.new(:name => 'puppetdbuser', bool_property => 'true')[bool_property]).to eq(:true)
        end

        it "should alias \"yes\" to :true" do
          expect(described_class.new(:name => 'puppetdbuser', bool_property => 'yes')[bool_property]).to eq(:true)
        end

        it "should allow false" do
          expect(described_class.new(:name => 'puppetdbuser', bool_property => false)[bool_property]).to eq(:false)
        end

        it "should alias \"false\" to :false" do
          expect(described_class.new(:name => 'puppetdbuser', bool_property => 'false')[bool_property]).to eq(:false)
        end

        it "should alias \"no\" to :false" do
          expect(described_class.new(:name => 'puppetdbuser', bool_property => 'no')[bool_property]).to eq(:false)
        end

        it "should not allow anything else" do
          expect { described_class.new(:name => 'puppetdbuser', bool_property => 'yess') }.to raise_error Puppet::Error, /Invalid value/
        end
      end
    end
  end
end
