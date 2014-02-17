Puppet PostgreSQL Module
=====================

[![Build Status](https://travis-ci.org/stschulte/puppet-postgres.png?branch=master)](https://travis-ci.org/stschulte/puppet-postgres)

Why another PostgreSQL module?
------------------------------
There are a bunch of available postgres modules on forge.puppetlabs.com
and I encourage you to look into these, because they let you install
postgres really easily. However these modules tend to be complex in order
to be shareable among different users with different usecases.

In contrast to other modules this postgres module does not aim to
deliver puppet classes that you can use right away, it does merely give you
new puppet types and providers to manage postgres databases and roles that
you can then use in your own puppet classes.


New facts
---------
(currently none)

New functions
-------------

### postgresql\_password

The `postgresql_password` function generates a crypted representation of
a clear text password. You have to provide two values: The username which
password you want to generate and the clear text password. The result
can be used as a `password` parameter to the `pg_role` type because this
one will expect the password to be already encrypted:

    pg_role { "postgres",
      ensure => present,
      password => postgresql_password('postgres', 'secr3t')
    }

New custom types
----------------

### Requirements

To be able to use the following types the `postgres` user has to
be able to access the database without password. This means you'll
probably want to have the following line in your `pg_hba.conf`

    # TYPE    DATABASE    USER        ADDRESS    METHOD
    local     all         postgres               ident
    ...

### pg\_database

The `pg_database` lets you describe a PostgreSQL database as a puppet
resource, so you can easily make sure that a certain database exists.

Let's say you write your own `puppetdb::database` class and inside that
class you want to make sure that a database called `puppetdb` exists:

    class puppetdb::database {
      pg_database { 'puppetdb':
        ensure   => present,
        owner    => 'puppetdb',
        encoding => 'UTF8',
      }
    }

If you want to be more explicit about encoding:

    pg_database { 'puppetdb':
      ensure   => present,
      owner    => 'puppetdb',
      encoding => 'UTF8',
      collate  => 'en_US.UTF-8',
      ctype    => 'en_US.UTF-8',
    }

Please note that puppet will check the `owner`, `encoding`, `collate`
and `ctype` property of existing databases, but it will only raise
an error when these values are different from the desired values. So they
are only taken into account when creating a new database - puppet will not
change the encodig of a database once it is created.

HINT: If you manage the owner with a `pg_role` resource, puppet will
automatically add a dependency between the role and the database so
the role will be created first.

### pg\_role

The `pg_role` type can be used to describe a PostgreSQL role as a puppet
resource. This way you can easily ensure that a certain user exists or
that a certain user has a specific password. Let's go back to the `puppetdb`
example and make sure that a proper user account exists:

    pg_role { 'puppetdb':
      ensure     => present,
      password   => 'md559faa421729e846dd800dce59943bfc0',
      superuser  => false,
      createdb   => false,
      createrole => false,
      inherit    => true,
      login      => true
    }
