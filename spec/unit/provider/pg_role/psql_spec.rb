#! /usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:pg_role).provider(:psql) do

  before :each do
    described_class.stubs(:command).with(:psql).returns '/foo/psql'
  end

  let :basic_psql_cmdline do
    %w{/foo/psql --no-password -c}
  end


  let :provider do
    described_class.new(
      :name       => 'puppetdbuser',
      :ensure     => :present,
      :password   => 'md559faa421729e846dd800dce59943bfc0',
      :superuser  => :false,
      :createdb   => :false,
      :createrole => :false,
      :inherit    => :true,
      :login      => :true
    )
  end

  describe "instance" do
    it "should correctly parse psql output" do
      cmdline = %w{/foo/psql --no-password --no-align --tuples-only -c}
      cmdline << 'select rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, passwd from pg_roles left outer join pg_shadow on rolname = usename;'

      described_class.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres').returns File.read(my_fixture('userlist'))
      instances = described_class.instances
      instances.size.should == 2

      instances[0].should be_exists
      instances[0].name.should == 'postgres'
      instances[0].password.should == :absent
      instances[0].superuser.should == :true
      instances[0].createdb.should == :true
      instances[0].createrole.should == :true
      instances[0].inherit.should == :true
      instances[0].login.should == :true

      instances[1].should be_exists
      instances[1].name.should == 'foobar'
      instances[1].password.should == 'md559faa421729e846dd800dce59943bfc0'
      instances[1].superuser.should == :false
      instances[1].createdb.should == :false
      instances[1].createrole.should == :false
      instances[1].inherit.should == :true
      instances[1].login.should == :true
    end
  end

  describe "when managing ensure" do
    describe "exists?" do
      it "should return true when the resource is present" do
        provider.set(:ensure => :present)
        provider.should be_exists
      end

      it "should return false when the resource is absent" do
        provider.set(:ensure => :absent)
        provider.should_not be_exists
      end
    end

    describe "create" do
      it "should create the database user" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser";}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass encrypted password if specified" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :password => 'md559faa421729e846dd800dce59943bfc0')
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" ENCRYPTED PASSWORD 'md559faa421729e846dd800dce59943bfc0';}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass SUPERUSER if superuser is true" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :superuser => true)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" SUPERUSER;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass NOSUPERUSER if superuser is false" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :superuser => false)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" NOSUPERUSER;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass CREATEDB if createdb is true" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :createdb => true)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" CREATEDB;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass NOCREATEDB if createdb is false" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :createdb => false)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" NOCREATEDB;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass CREATEROLE if createrole is true" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :createrole => true)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" CREATEROLE;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass NOCREATEROLE if createrole is false" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :createrole => false)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" NOCREATEROLE;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass INHERIT if inherit is true" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :inherit => true)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" INHERIT;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass NOINHERIT if inherit is false" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :inherit => false)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" NOINHERIT;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass LOGIN if login is true" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :login => true)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" LOGIN;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass NOLOGIN if login is false" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :provider => provider, :login => false)
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" NOLOGIN;}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end

      it "should pass every specified argument" do
        Puppet::Type.type(:pg_role).new(
          :name       => 'puppetdbuser',
          :password   => 'md559faa421729e846dd800dce59943bfc0',
          :superuser  => :false,
          :createdb   => :false,
          :createrole => :false,
          :inherit    => :true,
          :login      => :true,
          :provider   => provider
        )
        cmdline = basic_psql_cmdline
        cmdline << %q{CREATE ROLE "puppetdbuser" NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD 'md559faa421729e846dd800dce59943bfc0';}
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.create
      end
    end

    describe "destroy" do
      it "should execute DROP ROLE to drop the role" do
        Puppet::Type.type(:pg_role).new(:name => 'puppetdbuser', :ensure => :absent, :provider => provider)
        cmdline = basic_psql_cmdline

        cmdline << %q{DROP ROLE "puppetdbuser";}

        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.destroy
      end
    end
  end

  describe "when managing password" do
    it "should get the cached value when retrieving the current value" do
      provider.set(:password => 'md559faa421729e846dd800dce59943bfc0')
      provider.password.should == 'md559faa421729e846dd800dce59943bfc0'
    end

    it "should alter the role when setting a new password" do
      cmdline = basic_psql_cmdline
      cmdline << %q{ALTER ROLE "puppetdbuser" ENCRYPTED PASSWORD 'md541bba2226e61dc9e6eae488ab3d76aac';}
      provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
      provider.password = 'md541bba2226e61dc9e6eae488ab3d76aac'
    end

    it "should set a NULL password if the desired value is absent" do
      cmdline = basic_psql_cmdline
      cmdline << %q{ALTER ROLE "puppetdbuser" PASSWORD NULL;}
      provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
      provider.password = :absent
    end
  end

  {
    :superuser  => 'SUPERUSER',
    :createdb   => 'CREATEDB',
    :createrole => 'CREATEROLE',
    :inherit    => 'INHERIT',
    :login      => 'LOGIN'
  }.each_pair do |bool_property, sql_value|
    describe "when managing #{bool_property}" do
      it "should get the cached value when retrieving the current value" do
        provider.set(bool_property => :true)
        provider.send(bool_property).should == :true
        provider.set(bool_property => :false)
        provider.send(bool_property).should == :false
      end

      it "should pass #{sql_value} if the desired value is true" do
        cmdline = basic_psql_cmdline
        cmdline << "ALTER ROLE \"puppetdbuser\" #{sql_value};"
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.send("#{bool_property}=", :true)
      end

      it "should pass NO#{sql_value} if the desired value is false" do
        cmdline = basic_psql_cmdline
        cmdline << "ALTER ROLE \"puppetdbuser\" NO#{sql_value};"
        provider.expects(:execute).with(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
        provider.send("#{bool_property}=", :false)
      end
    end
  end
end
