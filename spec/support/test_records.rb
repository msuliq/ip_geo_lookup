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

  BR = {
    "country" => {"iso_code" => "BR", "names" => {"en" => "Brazil"}},
    "continent" => {"code" => "SA", "names" => {"en" => "Am\u00e9rica del Sur"}},
    "city" => {"names" => {"en" => "S\u00e3o Paulo"}},
    "subdivisions" => [{"names" => {"en" => "S\u00e3o Paulo"}}],
    "location" => {"latitude" => -23.5505, "longitude" => -46.6333, "time_zone" => "America/Sao_Paulo"},
    "postal" => {"code" => "01000"}
  }.freeze

  CH = {
    "country" => {"iso_code" => "CH", "names" => {"en" => "Switzerland"}},
    "continent" => {"code" => "EU", "names" => {"en" => "Europe"}},
    "city" => {"names" => {"en" => "Z\u00fcrich"}},
    "subdivisions" => [{"names" => {"en" => "Z\u00fcrich"}}],
    "location" => {"latitude" => 47.3769, "longitude" => 8.5417, "time_zone" => "Europe/Zurich"},
    "postal" => {"code" => "8001"}
  }.freeze

  # Arabic script
  EG = {
    "country" => {"iso_code" => "EG", "names" => {"en" => "\u0645\u0635\u0631"}},
    "continent" => {"code" => "AF", "names" => {"en" => "\u0623\u0641\u0631\u064a\u0642\u064a\u0627"}},
    "city" => {"names" => {"en" => "\u0627\u0644\u0642\u0627\u0647\u0631\u0629"}},
    "subdivisions" => [{"names" => {"en" => "\u0627\u0644\u0642\u0627\u0647\u0631\u0629"}}],
    "location" => {"latitude" => 30.0444, "longitude" => 31.2357, "time_zone" => "Africa/Cairo"},
    "postal" => {"code" => "11511"}
  }.freeze

  # Chinese characters
  CN = {
    "country" => {"iso_code" => "CN", "names" => {"en" => "\u4e2d\u56fd"}},
    "continent" => {"code" => "AS", "names" => {"en" => "\u4e9a\u6d32"}},
    "city" => {"names" => {"en" => "\u5317\u4eac"}},
    "subdivisions" => [{"names" => {"en" => "\u5317\u4eac\u5e02"}}],
    "location" => {"latitude" => 39.9042, "longitude" => 116.4074, "time_zone" => "Asia/Shanghai"},
    "postal" => {"code" => "100000"}
  }.freeze

  # Devanagari (Hindi)
  IN = {
    "country" => {"iso_code" => "IN", "names" => {"en" => "\u092d\u093e\u0930\u0924"}},
    "continent" => {"code" => "AS", "names" => {"en" => "\u090f\u0936\u093f\u092f\u093e"}},
    "city" => {"names" => {"en" => "\u092e\u0941\u0902\u092c\u0908"}},
    "subdivisions" => [{"names" => {"en" => "\u092e\u0939\u093e\u0930\u093e\u0937\u094d\u091f\u094d\u0930"}}],
    "location" => {"latitude" => 19.076, "longitude" => 72.8777, "time_zone" => "Asia/Kolkata"},
    "postal" => {"code" => "400001"}
  }.freeze

  # Japanese - Latin with macrons (realistic "en" locale data)
  JP = {
    "country" => {"iso_code" => "JP", "names" => {"en" => "Japan"}},
    "continent" => {"code" => "AS", "names" => {"en" => "Asia"}},
    "city" => {"names" => {"en" => "T\u014dky\u014d"}},
    "subdivisions" => [{"names" => {"en" => "T\u014dky\u014d"}}],
    "location" => {"latitude" => 35.6762, "longitude" => 139.6503, "time_zone" => "Asia/Tokyo"},
    "postal" => {"code" => "100-0001"}
  }.freeze

  # Armenian script
  AM = {
    "country" => {"iso_code" => "AM", "names" => {"en" => "\u0540\u0561\u0575\u0561\u057d\u057f\u0561\u0576"}},
    "continent" => {"code" => "AS", "names" => {"en" => "\u0531\u057d\u056b\u0561"}},
    "city" => {"names" => {"en" => "\u0535\u0580\u0587\u0561\u0576"}},
    "subdivisions" => [{"names" => {"en" => "\u0535\u0580\u0587\u0561\u0576"}}],
    "location" => {"latitude" => 40.1792, "longitude" => 44.4991, "time_zone" => "Asia/Yerevan"},
    "postal" => {"code" => "0010"}
  }.freeze

  # Georgian script
  GE = {
    "country" => {"iso_code" => "GE", "names" => {"en" => "\u10e1\u10d0\u10e5\u10d0\u10e0\u10d7\u10d5\u10d4\u10da\u10dd"}},
    "continent" => {"code" => "AS", "names" => {"en" => "\u10d0\u10d6\u10d8\u10d0"}},
    "city" => {"names" => {"en" => "\u10d7\u10d1\u10d8\u10da\u10d8\u10e1\u10d8"}},
    "subdivisions" => [{"names" => {"en" => "\u10d7\u10d1\u10d8\u10da\u10d8\u10e1\u10d8"}}],
    "location" => {"latitude" => 41.7151, "longitude" => 44.8271, "time_zone" => "Asia/Tbilisi"},
    "postal" => {"code" => "0100"}
  }.freeze

  # Hebrew script
  IL = {
    "country" => {"iso_code" => "IL", "names" => {"en" => "\u05d9\u05e9\u05e8\u05d0\u05dc"}},
    "continent" => {"code" => "AS", "names" => {"en" => "\u05d0\u05e1\u05d9\u05d4"}},
    "city" => {"names" => {"en" => "\u05d9\u05e8\u05d5\u05e9\u05dc\u05d9\u05dd"}},
    "subdivisions" => [{"names" => {"en" => "\u05de\u05d7\u05d5\u05d6 \u05d9\u05e8\u05d5\u05e9\u05dc\u05d9\u05dd"}}],
    "location" => {"latitude" => 31.7683, "longitude" => 35.2137, "time_zone" => "Asia/Jerusalem"},
    "postal" => {"code" => "9100000"}
  }.freeze
end
