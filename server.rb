require 'sinatra'
require 'json/ext'
load 'mongo_wrapper.rb'

mongo = MongoDb.new
LIMIT = 50

def get_page
  return params['page'].to_i if params['page'] && params['page'].respond_to?(:to_i) && params['page'].to_i > 1
  return 1 unless params['page'] && params['page'].respond_to?(:to_i) && params['page'].to_i > 1
end

def to_skip
  return (get_page - 1) * LIMIT
end

def paginated result
  return result.skip(to_skip).limit(LIMIT).to_a.to_json
end

def get_value value, type
  case type
  when 'string'
      return value.to_s
    when 'int'
      return value.to_i
    when 'float'
      return value.to_f
  end
end

before do
  content_type 'application/json'
end

allowed_params = {:name => 'string', :lat => 'float', :lon => 'float',
                  :_id => 'int', :zip => 'int', :cvr => 'int', :pnr => 'int',
                  :elite => 'int', :street => 'string'}
get '/search' do
  query = Hash.new
  params.each_key do |key|
    if allowed_params.has_key? key.to_sym
      puts key
      puts params[key]
      value = get_value(params[key], allowed_params[key.to_sym])
      puts value.inspect
      query[key.to_sym] = /#{value}/i if allowed_params[key.to_sym] == 'string'
      query[key.to_sym] = value unless allowed_params[key.to_sym] == 'string'
    end
  end
  return paginated(mongo.collection.find(query))
end

get '/' do
	erb :index
end

get '/near/:lat/:lon/:max_dist' do
  latitude = params['lat'].to_f
  longitude = params['lon'].to_f
  max_distance = params['max_dist'].to_i
  return mongo.collection.find({:geo_location => {:$near => { :$geometry => { :type => "Point", :coordinates => [latitude, longitude]}, :$maxDistance => max_distance}}}).skip(to_skip).limit(@@limit).map(&:inspect) #.skip(to_skip).limit(@@limit).map(&:inspect)
end
