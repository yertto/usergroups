require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new(STDOUT, :debug) if ENV['DEBUG']
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/devel.db")


class User
  include DataMapper::Resource
  property :id   , Serial  , :key => true
  property :pin  , Integer

  has n, :groups , :through => Resource

  def to_s
    "#{self.class.name}#{'%03d' % id}"
  end
end


class Group
  include DataMapper::Resource
  property :id   , Serial  , :key => true

  has n, :users , :through => Resource

  def to_s
    "#{self.class.name}#{'%03d' % id}"
  end
end



DataMapper.auto_upgrade!
#DataMapper.auto_migrate!

