Puppet::Type.type(:pg_database).provide(:psql) do

  commands :psql     => '/usr/bin/psql'
  commands :createdb => '/usr/bin/createdb'
  commands :dropdb   => '/usr/bin/dropdb'

  def self.instances
    instances = []
    cmdline = [ command(:psql) ]
    cmdline << '--no-password' << '--no-align' << '--tuples-only' << '--list'
    execute(cmdline, :uid => 'postgres').each_line do |line|
      if match = /^(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)\|/.match(line.chomp)
        instances << new(
          :name     => match.captures[0],
          :ensure   => :present,
          :owner    => match.captures[1],
          :encoding => match.captures[2],
          :collate  => match.captures[3],
          :ctype    => match.captures[4]
        )
      end
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

  def create
    cmdline = [ command(:createdb) ]
    cmdline << '--no-password'
    cmdline << "--encoding=#{resource[:encoding]}" if resource[:encoding]
    cmdline << "--lc-collate=#{resource[:collate]}" if resource[:collate]
    cmdline << "--lc-ctype=#{resource[:ctype]}" if resource[:ctype]
    cmdline << "--owner=#{resource[:owner]}" if resource[:owner]
    cmdline << resource[:name]
    execute(cmdline, :uid => 'postgres')
  end

  def destroy
    cmdline = [ command(:dropdb) ]
    cmdline << '--no-password' << resource[:name]
    execute(cmdline, :uid => 'postgres')
  end

  def exists?
    get(:ensure) != :absent
  end

  [:owner, :encoding, :collate, :ctype].each do |property|
    define_method(property) do
      @property_hash[property]
    end

    define_method(property.to_s + "=") do |val|
      raise Puppet::Error, "Changing #{property} of an already existing database is currently not supported. Please perform the necessary steps manually"
    end
  end
end
