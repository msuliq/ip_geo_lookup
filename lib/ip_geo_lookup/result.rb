# frozen_string_literal: true

module IpGeoLookup
  class Result
    include Comparable

    FIELDS = [
      :country_code, :country_name, :region, :city,
      :continent_code, :continent_name,
      :latitude, :longitude, :time_zone, :postal_code
    ].freeze

    attr_reader :country_code, :country_name, :region, :city,
      :continent_code, :continent_name,
      :latitude, :longitude, :time_zone, :postal_code,
      :raw

    def initialize(country_code:, country_name:, region:, city:,
      continent_code: nil, continent_name: nil,
      latitude: nil, longitude: nil,
      time_zone: nil, postal_code: nil,
      raw: nil)
      @country_code = country_code
      @country_name = country_name
      @region = region
      @city = city
      @continent_code = continent_code
      @continent_name = continent_name
      @latitude = latitude
      @longitude = longitude
      @time_zone = time_zone
      @postal_code = postal_code
      @raw = raw
    end

    def [](key)
      case key.to_sym
      when :country_code then @country_code
      when :country_name then @country_name
      when :region then @region
      when :city then @city
      when :continent_code then @continent_code
      when :continent_name then @continent_name
      when :latitude then @latitude
      when :longitude then @longitude
      when :time_zone then @time_zone
      when :postal_code then @postal_code
      when :raw then @raw
      end
    end

    def to_h
      {
        country_code: @country_code,
        country_name: @country_name,
        region: @region,
        city: @city,
        continent_code: @continent_code,
        continent_name: @continent_name,
        latitude: @latitude,
        longitude: @longitude,
        time_zone: @time_zone,
        postal_code: @postal_code
      }
    end

    def to_a
      [@country_code, @country_name, @region, @city,
        @continent_code, @continent_name,
        @latitude, @longitude, @time_zone, @postal_code]
    end

    def members
      FIELDS.dup
    end

    def to_s
      location = [@city, @region, @country_name].reject { |s| s.nil? || s.empty? }.join(", ")
      if @country_code && !@country_code.empty?
        location.empty? ? @country_code : "#{location} (#{@country_code})"
      else
        location
      end
    end

    def inspect
      "#<IpGeoLookup::Result #{self}>"
    end

    def <=>(other)
      return nil unless other.is_a?(Result)
      [country_code.to_s, region.to_s, city.to_s] <=> [other.country_code.to_s, other.region.to_s, other.city.to_s]
    end

    # Equality based on to_h; raw is intentionally excluded.
    def ==(other)
      return false unless other.is_a?(Result)
      to_h == other.to_h
    end

    alias_method :eql?, :==

    def hash
      to_h.hash
    end
  end
end
