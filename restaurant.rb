class Restaurant
  attr_accessor :id, :name, :street,
                :zip, :city, :geo_location,
                :cvr, :url, :elite, :pixi,
                :controls, :pnr, :businessCode,
                :business, :businessType, :advertisementProtection

  def initialize
    @geo_location = Location.new(0, 0)
    @controls = []
  end

  def is_elite
    case @elite.to_i
      when 0
        return 'Ikke Elite'
      when 1
        return 'Elite'
      when 2
        return 'Ikke muligt'
    end
  end

  def self.map_from_xml entry
    rest = Restaurant.new
    rest.id = entry.attr('navnelbnr').to_i
    rest.name = entry.attr('navn1').rstrip
    rest.street = entry.attr('adresse1').rstrip
    rest.zip = entry.attr('postnr').to_i
    rest.city = (if entry.attr('By') then entry.attr('By') else "" end).rstrip
    rest.geo_location = Location.new(entry.attr('Geo_Lat'), entry.attr('Geo_Lng'))
    rest.cvr = entry.attr('cvrnr').to_i
    rest.pnr = entry.attr('pnr').to_i
    rest.url = (if entry.attr('URL') then entry.attr('URL') else "http://www.findsmiley.dk/da-DK/Searching/DetailsView.htm?virk=#{rest.id}" end).rstrip
    rest.elite = entry.attr('Elite_Smiley').to_i
    rest.businessCode = entry.attr('brancheKode').rstrip
    rest.business = entry.attr('branche').rstrip
    rest.businessType = entry.attr('virksomhedstype').rstrip
    rest.advertisementProtection = entry.attr('reklame_beskyttelse') == 1
    rest.pixi = entry.attr('pixibranche').rstrip

    if entry.attr('seneste_kontrol') && entry.attr('seneste_kontrol_dato')
      control = Control.new
      control.smiley = entry.attr('seneste_kontrol')
      control.date = Date.parse(entry.attr('seneste_kontrol_dato'))
      rest.controls << control
    end

    if entry.attr('naestseneste_kontrol') && entry.attr('naestseneste_kontrol_dato')
      control = Control.new
      control.smiley = entry.attr('naestseneste_kontrol')
      control.date = Date.parse(entry.attr('naestseneste_kontrol_dato'))
      rest.controls << control
    end

    if entry.attr('tredjeseneste_kontrol') && entry.attr('tredjeseneste_kontrol_dato')
      control = Control.new
      control.smiley = entry.attr('tredjeseneste_kontrol')
      control.date = Date.parse(entry.attr('tredjeseneste_kontrol_dato'))
      rest.controls << control
    end

    if entry.attr('fjerdeseneste_kontrol') && entry.attr('fjerdeseneste_kontrol_dato')
      control = Control.new
      control.smiley = entry.attr('fjerdeseneste_kontrol')
      control.date = Date.parse(entry.attr('fjerdeseneste_kontrol_dato'))
      rest.controls << control
    end

    return rest
  end

  def to_h
    return {
      :_id => @id.to_i, #_id is the Id in MongoDb
      :name => @name,
      :street => @street,
      :zip => @zip.to_i,
      :city => @city,
      :geo_location => @geo_location.to_h,
      :cvr => @cvr.to_i,
      :business => @business,
      :businessType => @businessType,
      :pnr => @pnr.to_i,
      :businessCode => @businessCode,
      :url => @url,
      :advertisementProtection => @advertisementProtection,
      :pixi => @pixi,
      :elite => @elite.to_i,
      :controls => @controls.map(&:to_h)
    }
  end

end

class Control
  attr_accessor :smiley, :date
  def to_h
    return {
      :smiley => @smiley.to_i,
      :date => @date
    }
  end
end

class Location
  attr_accessor :longitude, :latitude
  def initialize(lat, lon)
    @latitude = lat.to_f
    @longitude = lon.to_f
  end

  def to_h
    return {
      :type => "Point",
      :coordinates => [@longitude.to_f, @latitude.to_f]
    }
  end
end
