Puppet::Type.type(:pg_role).provide(:psql) do

  commands :psql => '/usr/bin/psql'

  def self.runsql(sql_statement)
    cmdline = [ command(:psql), '--no-password', '--no-align', '--tuples-only', '-c', sql_statement ]
    execute(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
  end

  def runsql(sql_statement)
    cmdline = [ command(:psql), '--no-password', '-c', sql_statement ]
    execute(cmdline, :failonfail => true, :combine => true, :uid => 'postgres')
  end

  def self.instances
    instances = []
    output = runsql('select rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, passwd from pg_roles left outer join pg_shadow on rolname = usename;')
    output.each_line do |line|
      fields = line.chomp.split('|')
      instances << new(
        :name        => fields[0],
        :ensure      => :present,
        :superuser   => (fields[1] == 't') ? :true : :false,
        :inherit     => (fields[2] == 't') ? :true : :false,
        :createrole  => (fields[3] == 't') ? :true : :false,
        :createdb    => (fields[4] == 't') ? :true : :false,
        :login       => (fields[5] == 't') ? :true : :false,
        :password    => (fields[6] || :absent)
      )
    end
    instances
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def exists?
    get(:ensure) != :absent
  end

  def bool_to_sql(property, true_value, false_value)
    case property
    when :true
      true_value
    when :false
      false_value
    else
      ""
    end
  end

  def create
    sql = "CREATE ROLE \"#{resource[:name]}\""
    sql += bool_to_sql(resource[:superuser], ' SUPERUSER', ' NOSUPERUSER')
    sql += bool_to_sql(resource[:createdb], ' CREATEDB', ' NOCREATEDB')
    sql += bool_to_sql(resource[:createrole], ' CREATEROLE', ' NOCREATEROLE')
    sql += bool_to_sql(resource[:inherit], ' INHERIT', ' NOINHERIT')
    sql += bool_to_sql(resource[:login], ' LOGIN', ' NOLOGIN')
    sql += " ENCRYPTED PASSWORD '#{resource[:password]}'" if resource[:password] and resource[:password] != :absent
    sql += ";"
    runsql(sql)
  end

  def destroy
    runsql("DROP ROLE \"#{name}\";")
  end

  [ :password, :superuser, :createdb, :createrole, :inherit, :login ].each do |property|
    define_method(property) do
      @property_hash[property]
    end
  end

  def password=(new_value)
    sql = case new_value
    when :absent
      "ALTER ROLE \"#{name}\" PASSWORD NULL;"
    else
      "ALTER ROLE \"#{name}\" ENCRYPTED PASSWORD '#{new_value}';"
    end
    runsql(sql)
  end

  def superuser=(new_value)
    token = new_value == :true ? 'SUPERUSER' : 'NOSUPERUSER'
    sql= "ALTER ROLE \"#{name}\" #{token};"
    runsql(sql)
  end

  def createdb=(new_value)
    token = new_value == :true ? 'CREATEDB' : 'NOCREATEDB'
    sql= "ALTER ROLE \"#{name}\" #{token};"
    runsql(sql)
  end

  def createrole=(new_value)
    token = new_value == :true ? 'CREATEROLE' : 'NOCREATEROLE'
    sql= "ALTER ROLE \"#{name}\" #{token};"
    runsql(sql)
  end

  def inherit=(new_value)
    token = new_value == :true ? 'INHERIT' : 'NOINHERIT'
    sql= "ALTER ROLE \"#{name}\" #{token};"
    runsql(sql)
  end

  def login=(new_value)
    token = new_value == :true ? 'LOGIN' : 'NOLOGIN'
    sql= "ALTER ROLE \"#{name}\" #{token};"
    runsql(sql)
  end
end
