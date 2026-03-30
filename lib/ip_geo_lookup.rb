# frozen_string_literal: true

require_relative "ip_geo_lookup/version"
require_relative "ip_geo_lookup/result"
require_relative "ip_geo_lookup/ip_address"
require_relative "ip_geo_lookup/mmdb"

module IpGeoLookup
  DEFAULT_DB_PATH = File.expand_path("../../data/GeoLite2-City.mmdb", __FILE__).freeze

  @mutex = Mutex.new

  class << self
    # Returns a Result for the given IP string, or nil.
    def lookup(ip_address)
      return nil unless ip_address.is_a?(String)

      parsed = IpAddress.parse(ip_address)
      return nil unless parsed

      ip_int, version = parsed
      record = reader.find(ip_int, (version == 6) ? 128 : 32)
      return nil unless record

      build_result(record)
    end

    def metadata
      reader.metadata
    end

    # Reloads from disk; respects configured path.
    def reload!
      @mutex.synchronize { @reader = nil }
    end

    def close
      @mutex.synchronize do
        @reader&.close
        @reader = nil
      end
    end

    def configure
      @mutex.synchronize do
        yield configuration
        @reader = MMDB.new(configuration.database_path, mode: configuration.mode)
      end
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset!
      @mutex.synchronize do
        @reader = nil
        @configuration = nil
      end
    end

    private

    def reader
      @mutex.synchronize do
        @reader ||= MMDB.new(configuration.database_path, mode: configuration.mode)
      end
    end

    def build_result(record)
      Result.new(
        country_code: deep_fetch(record, "country", "iso_code"),
        country_name: deep_fetch(record, "country", "names", "en"),
        region: deep_fetch(record, "subdivisions", 0, "names", "en"),
        city: deep_fetch(record, "city", "names", "en"),
        continent_code: deep_fetch(record, "continent", "code"),
        continent_name: deep_fetch(record, "continent", "names", "en"),
        latitude: deep_fetch(record, "location", "latitude"),
        longitude: deep_fetch(record, "location", "longitude"),
        time_zone: deep_fetch(record, "location", "time_zone"),
        postal_code: deep_fetch(record, "postal", "code"),
        raw: record
      )
    end

    def deep_fetch(obj, *keys)
      keys.each do |key|
        case obj
        when Hash then obj = obj[key]
        when Array then obj = obj[key]
        else return nil
        end
      end
      obj
    end
  end

  class Configuration
    attr_writer :database_path, :mode

    def database_path
      @database_path || DEFAULT_DB_PATH
    end

    def mode
      @mode || MMDB::MODE_FILE
    end
  end
end
