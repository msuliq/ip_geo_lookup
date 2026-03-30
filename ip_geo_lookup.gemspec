# frozen_string_literal: true

require_relative "lib/ip_geo_lookup/version"

Gem::Specification.new do |spec|
  spec.name = "ip_geo_lookup"
  spec.version = IpGeoLookup::VERSION
  spec.authors = ["Suleyman Musayev"]
  spec.email = ["slmusayev@gmail.com"]

  spec.summary = "Zero-dependency IPv4/IPv6 geolocation lookup with embedded MaxMind database"
  spec.description = "A lightweight, zero-dependency Ruby gem for resolving IPv4 and IPv6 addresses " \
                        "to country, region, city, coordinates, and more. Ships with an embedded " \
                        "MaxMind GeoLite2 MMDB database and a pure Ruby MMDB reader - no external " \
                        "gems, no API keys, no setup."
  spec.homepage = "https://github.com/msuliq/ip_geo_lookup"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/msuliq/ip_geo_lookup",
    "changelog_uri" => "https://github.com/msuliq/ip_geo_lookup/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/msuliq/ip_geo_lookup/issues"
  }

  spec.files = Dir.chdir(__dir__) do
    Dir["{lib,data}/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  end

  spec.require_paths = ["lib"]
end
