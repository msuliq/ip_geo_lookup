# frozen_string_literal: true

# Shared test records used across all specs.
module TestRecords
  AU = {
    "country" => {"iso_code" => "AU", "names" => {"en" => "Australia"}},
    "continent" => {"code" => "OC", "names" => {"en" => "Oceania"}},
    "city" => {"names" => {"en" => "Sydney"}},
    "subdivisions" => [{"names" => {"en" => "New South Wales"}}],
    "location" => {"latitude" => -33.8688, "longitude" => 151.2093, "time_zone" => "Australia/Sydney"},
    "postal" => {"code" => "2000"}
  }.freeze

  US = {
    "country" => {"iso_code" => "US", "names" => {"en" => "United States"}},
    "continent" => {"code" => "NA", "names" => {"en" => "North America"}},
    "city" => {"names" => {"en" => "Mountain View"}},
    "subdivisions" => [{"names" => {"en" => "California"}}],
    "location" => {"latitude" => 37.386, "longitude" => -122.0838, "time_zone" => "America/Los_Angeles"},
    "postal" => {"code" => "94035"}
  }.freeze

  DE = {
    "country" => {"iso_code" => "DE", "names" => {"en" => "Germany"}},
    "continent" => {"code" => "EU", "names" => {"en" => "Europe"}},
    "city" => {"names" => {"en" => "Frankfurt"}},
    "subdivisions" => [{"names" => {"en" => "Hesse"}}],
    "location" => {"latitude" => 50.1109, "longitude" => 8.6821, "time_zone" => "Europe/Berlin"},
    "postal" => {"code" => "60306"}
  }.freeze
end
