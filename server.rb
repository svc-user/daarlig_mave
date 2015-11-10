require 'sinatra'
load 'mongo_wrapper.rb'

mongo = MongoDb.new
@@limit = 50

def get_page
  return params['page'].to_i if params['page'] && params['page'].respond_to?(:to_i) && params['page'].to_i > 1
  return 1 unless params['page'] && params['page'].respond_to?(:to_i) && params['page'].to_i > 1
end

def to_skip
  return (get_page - 1) * @@limit
end

before do
  content_type 'application/json'
end

get '/' do
	erb :index
end

get '/name/:name' do
  return mongo.collection.find({:name => /#{params['name']}/i}).limit(@@limit).map(&:inspect)
end

get '/near/:lat/:lon/:max_dist' do
  latitude = params['lat'].to_f
  longitude = params['lon'].to_f
  max_distance = params['max_dist'].to_i
  return mongo.collection.find({:geo_location => {:$near => { :$geometry => { :type => "Point", :coordinates => [latitude, longitude]}, :$maxDistance => max_distance}}}).skip(to_skip).limit(@@limit).map(&:inspect) #.skip(to_skip).limit(@@limit).map(&:inspect)
end

get '/zip/:zip' do
  return mongo.collection.find({:zip => params['zip'].to_i}).skip(to_skip).limit(@@limit).map(&:inspect)
end

get '/id/:id' do
  return mongo.collection.find({:_id => params['id'].to_i}).to_a.first.inspect
end

get '/cvr/:cvr' do
  return mongo.collection.find({:cvr => params['cvr'].to_i}).skip(to_skip).limit(@@limit).map(&:inspect)
end

get '/pnr/:pnr' do
  return mongo.collection.find({:pnr => params['pnr'].to_i}).skip(to_skip).limit(@@limit).map(&:inspect)
end

get '/elite/:elite' do
  return mongo.collection.find({:elite => params['elite'].to_i}).skip(to_skip).limit(@@limit).map(&:inspect)
end
