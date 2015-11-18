require 'sinatra'
require 'json/ext'
load 'mongo_wrapper.rb'

mongo = MongoDb.new
LIMIT = 50

before do
  content_type 'application/json', 'charset' => 'UTF-8'
end

allowed_params = {:name => 'string', :lat => 'float', :lon => 'float', :max_dist => 'int',
                  :_id => 'int', :zip => 'int', :cvr => 'int', :pnr => 'int',
                  :elite => 'int', :street => 'string', :city => 'string',
                  :advertisementProtection => 'bool'}
get '/search' do
  query = Hash.new

  #Add lat+long query if both are present
  if params.has_key?('lon') && params.has_key?('lat')
    lat = params['lat'].to_f
    lon = params['lon'].to_f
    max_dist = if params['max_dist'] then params['max_dist'].to_i else 500 end

    query[:geo_location] = {:$near => {:$geometry => {:type => 'Point', :coordinates => [lat, lon]}, :$maxDistance => max_dist}}

    params.delete 'lat'
    params.delete 'lon'
    params.delete 'max_dist'
  end

  params.each_key do |key|
    if allowed_params.has_key? key.to_sym
      puts key
      value = get_value(params[key], allowed_params[key.to_sym])
      puts value.inspect
      query[key.to_sym] = /#{value}/i if allowed_params[key.to_sym] == 'string'
      query[key.to_sym] = value unless allowed_params[key.to_sym] == 'string'
    end
  end
  return paginated(mongo.collection.find(query))
end

get '/' do
  content_type 'text/html'
	erb :index
end


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
    when 'bool'
      if value.downcase == 'true' || value.downcase == 'false'
        return value.downcase == 'true'
      else
        return value.to_i != 0
      end
  end
end
