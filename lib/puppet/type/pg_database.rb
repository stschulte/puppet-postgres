Puppet::Type.newtype(:pg_database) do

  @doc = "The `pg_database` resource type describes a PostgreSQL database
    and can be used to ensure the existance of a certain database.

    Example:

        pg_database { 'puppetdb':
          ensure   => present,
          owner    => 'puppetdb',
          encoding => 'UTF8'
          locale   => 'en_US.UTF-8',
          collate  => 'en_US.UTF-8',
          ctype    => 'en_US.UTF-8',
        }"

  newparam(:name) do
    desc "The name of the database instance."
  end

  ensurable

  newproperty(:owner) do
    desc "The owner of the database. The owner has to a database role that already exists."
  end

  newproperty(:encoding) do
    desc "Specifies the character encoding scheme to be used in this database, like `UTF8`"
    newvalues :LATIN1, :LATIN9, :UTF8
  end

  newproperty(:collate) do
    desc "Specifies the LC_COLLATE setting to be used in this database."
  end

  newproperty(:ctype) do
    desc "Specifies the LC_CTYPE setting to be used in this database."
  end

  autorequire(:pg_role) do
    self[:owner]
  end
end
