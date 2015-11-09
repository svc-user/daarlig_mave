require 'mongo'
require 'net/http'

class MongoDb
  attr_accessor :db, :collection
  def initialize
    Mongo::Logger.logger.level = Logger::WARN
    @db = Mongo::Client.new('mongodb://127.0.0.1:27017/daarlig_mave')
    @collection = @db[:restaurants]
  end
end
