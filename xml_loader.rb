class Xml_loader
  require 'nokogiri'
  require 'time'
  load 'mongo_wrapper.rb'
  load 'restaurant.rb'

  def main
    system 'wget -q http://www.findsmiley.dk/xml/allekontrolresultater.xml -O allekontrolresultater_full.xml'

    restaurants = []
    counter = 0

    mongo = MongoDb.new
    puts 'Clearing mongo'
    mongo.collection.delete_many

    puts 'Mapping and indexing'
    File.open("allekontrolresultater_full.xml", "r") do |f|
      f.each_line do |line|
        doc = Nokogiri::XML("<root>" + line + "</root>")
        doc.xpath('//row').each do |entry|
          rest = Restaurant.map_from_xml entry
          restaurants << rest
          counter += 1
          if counter % 1000 == 0
            mongo.collection.insert_many(restaurants.map(&:to_h))
            restaurants = []
            puts "Added #{counter} restaurants to mongo.."
          end
        end
      end
    end
    mongo.collection.insert_many(restaurants.map(&:to_h))
    puts "Added #{counter} restaurants to mongo.."
    puts 'Success!'
  end


end

Xml_loader.new.main()
