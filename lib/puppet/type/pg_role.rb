require 'puppet/property/boolean'

Puppet::Type.newtype(:pg_role) do
  @doc = "Manages a PostgreSQL role as a puppet resource"

  newparam(:name) do
    desc "The name of the role"
    isnamevar
  end

  ensurable

  newproperty(:password) do
    desc "The hashed password of the database user"
  end

  newproperty(:superuser, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc "If set to `true`, the new role will be a superuser, who can override all access restrictions within the database. Superuser status is dangerous and should be used only when really needed."
  end

  newproperty(:createdb, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc "If set to `true`, the role being defined will be allowed to create new databases. Specifying `false` will deny the new role the ability to create databases."
  end

  newproperty(:createrole, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc "If set to `true`, the new role will be permitted to create new roles (that is, execute CREATE ROLE). The role will also be able to alter and drop other roles."
  end

  newproperty(:inherit, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc "If set to `true`, the new role inherits the privileges of roles it is a member of."
  end

  newproperty(:login, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc "If set to `true`, the role will be allowed to log in. A role having the LOGIN attribute can be thought of as a user. Roles without this attribute are useful for managing database privileges, but are not users in the usual sense of the word."
  end

end
