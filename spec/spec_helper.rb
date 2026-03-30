# frozen_string_literal: true

require "ip_geo_lookup"
require_relative "support/mmdb_builder"
require_relative "support/test_records"

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")

RSpec.configure do |config|
  config.expect_with(:rspec) { |e| e.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { |m| m.verify_partial_doubles = true }
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    MMDBBuilder.write(File.join(FIXTURES_DIR, "ipv4.mmdb"),
      ip_version: 4, record_size: 24,
      records: {"64.0.0.0/2" => TestRecords::AU, "128.0.0.0/2" => TestRecords::US})

    [28, 32].each do |rs|
      MMDBBuilder.write(File.join(FIXTURES_DIR, "ipv4_rs#{rs}.mmdb"),
        ip_version: 4, record_size: rs,
        records: {"128.0.0.0/1" => TestRecords::DE})
    end

    MMDBBuilder.write(File.join(FIXTURES_DIR, "ipv6.mmdb"),
      ip_version: 6, record_size: 28,
      records: {"2001::/16" => TestRecords::DE, "2600::/16" => TestRecords::US})

    MMDBBuilder.write(File.join(FIXTURES_DIR, "ipv6_with_v4.mmdb"),
      ip_version: 6, record_size: 28,
      records: {"2001::/16" => TestRecords::DE, "4000::/2" => TestRecords::AU})
  end

  config.after(:each) { IpGeoLookup.reset! }
end
