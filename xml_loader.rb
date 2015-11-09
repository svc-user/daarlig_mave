class Xml_loader
  require 'nokogiri'
  require 'time'
  load 'mongo_wrapper.rb'
  load 'restaurant.rb'
  
  def main
    #system 'wget http://www.findsmiley.dk/xml/allekontrolresultater.xml -O allekontrolresultater_full.xml'

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
=begin
<row
  navnelbnr="547353"
  cvrnr="29189471"
  pnr="1003377228"
  brancheKode="56.29.00.E"
  branche="Servering: Institutioner for børn i skolealderen"
  virksomhedstype="Detail"
  navn1="Strandby Skole "
  adresse1="Farsøvej 13"
  postnr="9640"
  By="Farsø"
  seneste_kontrol="1"
  seneste_kontrol_dato="2014-09-09T00:00:00"
  URL="http://www.findsmiley.dk/da-DK/Searching/DetailsView.htm?virk=547353"
  reklame_beskyttelse="0"
  Elite_Smiley="0"
  Geo_Lng="9.216524"
  Geo_Lat="56.791186"
  pixibranche="Børneinstitutioner"/>

<row
  navnelbnr="10825581"
  cvrnr="27486134"
  pnr="1010267974"
  brancheKode="56.29.00.D"
  branche="Servering: Institutioner med madordning for førskolebørn"
  virksomhedstype="Detail"
  navn1="Børnehaven Bitte Bæk "
  adresse1="Saxogade 4"
  postnr="9000"
  By="Aalborg"
  seneste_kontrol="1"
  seneste_kontrol_dato="2015-01-30T00:00:00"
  naestseneste_kontrol="1"
  naestseneste_kontrol_dato="2013-01-23T00:00:00"
  tredjeseneste_kontrol="1"
  tredjeseneste_kontrol_dato="2011-11-07T10:36:00"
  fjerdeseneste_kontrol="1"
  fjerdeseneste_kontrol_dato="2010-11-11T10:55:00"
  URL="http://www.findsmiley.dk/da-DK/Searching/DetailsView.htm?virk=10825581"
  reklame_beskyttelse="0"
  Elite_Smiley="1"
  Geo_Lng="9.910044"
  Geo_Lat="57.049439"
  pixibranche="Børneinstitutioner"/>
=end
