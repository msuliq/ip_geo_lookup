# frozen_string_literal: true

RSpec.describe IpGeoLookup::Result do
  subject(:result) do
    described_class.new(
      country_code: "US",
      country_name: "United States",
      region: "California",
      city: "Mountain View",
      continent_code: "NA",
      continent_name: "North America",
      latitude: 37.386,
      longitude: -122.0838,
      time_zone: "America/Los_Angeles",
      postal_code: "94035",
      raw: {"country" => {"iso_code" => "US"}}
    )
  end

  describe "attribute readers" do
    it "returns core fields" do
      expect(result.country_code).to eq("US")
      expect(result.country_name).to eq("United States")
      expect(result.region).to eq("California")
      expect(result.city).to eq("Mountain View")
    end

    it "returns extended fields" do
      expect(result.continent_code).to eq("NA")
      expect(result.continent_name).to eq("North America")
      expect(result.latitude).to eq(37.386)
      expect(result.longitude).to eq(-122.0838)
      expect(result.time_zone).to eq("America/Los_Angeles")
      expect(result.postal_code).to eq("94035")
    end

    it "returns raw record" do
      expect(result.raw).to eq({"country" => {"iso_code" => "US"}})
    end
  end

  describe "backward compatibility" do
    it "works with only the 4 core fields" do
      r = described_class.new(
        country_code: "US", country_name: "United States",
        region: "California", city: "Mountain View"
      )
      expect(r.country_code).to eq("US")
      expect(r.latitude).to be_nil
      expect(r.raw).to be_nil
    end
  end

  describe "#[]" do
    it "supports symbol keys for all fields" do
      expect(result[:country_code]).to eq("US")
      expect(result[:continent_code]).to eq("NA")
      expect(result[:latitude]).to eq(37.386)
      expect(result[:time_zone]).to eq("America/Los_Angeles")
      expect(result[:postal_code]).to eq("94035")
      expect(result[:raw]).to eq({"country" => {"iso_code" => "US"}})
    end

    it "supports string keys" do
      expect(result["country_code"]).to eq("US")
      expect(result["latitude"]).to eq(37.386)
    end

    it "returns nil for unknown keys" do
      expect(result[:unknown]).to be_nil
    end
  end

  describe "#to_h" do
    it "returns a hash with all fields (excluding raw)" do
      h = result.to_h
      expect(h[:country_code]).to eq("US")
      expect(h[:continent_code]).to eq("NA")
      expect(h[:latitude]).to eq(37.386)
      expect(h[:postal_code]).to eq("94035")
      expect(h).not_to have_key(:raw)
    end
  end

  describe "#to_a" do
    it "returns values in FIELDS order" do
      expect(result.to_a).to eq([
        "US", "United States", "California", "Mountain View",
        "NA", "North America", 37.386, -122.0838,
        "America/Los_Angeles", "94035"
      ])
    end
  end

  describe "#members" do
    it "returns all field names" do
      expect(result.members).to include(:country_code, :continent_code, :latitude, :postal_code)
    end
  end

  describe "#to_s" do
    it "returns a human-readable string with core fields" do
      expect(result.to_s).to eq("Mountain View, California, United States (US)")
    end

    it "handles empty city" do
      r = described_class.new(country_code: "US", country_name: "United States", region: "California", city: "")
      expect(r.to_s).to eq("California, United States (US)")
    end

    it "handles empty city and region" do
      r = described_class.new(country_code: "US", country_name: "United States", region: "", city: "")
      expect(r.to_s).to eq("United States (US)")
    end

    it "handles nil fields" do
      r = described_class.new(country_code: nil, country_name: nil, region: nil, city: nil)
      expect(r.to_s).to eq("")
    end
  end

  describe "#inspect" do
    it "returns a debug string" do
      expect(result.inspect).to eq("#<IpGeoLookup::Result Mountain View, California, United States (US)>")
    end
  end

  describe "Comparable" do
    it "supports <=>" do
      au = described_class.new(country_code: "AU", country_name: "Australia", region: "Queensland", city: "Brisbane")
      expect(result <=> au).to eq(1)
    end

    it "supports sorting" do
      au = described_class.new(country_code: "AU", country_name: "Australia", region: "Queensland", city: "Brisbane")
      cn = described_class.new(country_code: "CN", country_name: "China", region: "Fujian", city: "Fuzhou")
      sorted = [result, au, cn].sort
      expect(sorted.map(&:country_code)).to eq(["AU", "CN", "US"])
    end

    it "returns nil when compared to non-Result" do
      expect(result <=> "US").to be_nil
    end
  end

  describe "#==" do
    it "is equal to another Result with the same fields" do
      other = described_class.new(
        country_code: "US", country_name: "United States",
        region: "California", city: "Mountain View",
        continent_code: "NA", continent_name: "North America",
        latitude: 37.386, longitude: -122.0838,
        time_zone: "America/Los_Angeles", postal_code: "94035"
      )
      expect(result).to eq(other)
    end

    it "ignores raw when comparing (raw is not part of to_h)" do
      a = described_class.new(country_code: "US", country_name: "US", region: "", city: "", raw: {"a" => 1})
      b = described_class.new(country_code: "US", country_name: "US", region: "", city: "", raw: {"b" => 2})
      expect(a).to eq(b)
    end

    it "is not equal to a Result with different values" do
      other = described_class.new(country_code: "AU", country_name: "Australia", region: "Queensland", city: "Brisbane")
      expect(result).not_to eq(other)
    end

    it "is not equal to non-Result objects" do
      expect(result).not_to eq("US")
    end
  end

  describe "#hash" do
    it "is equal for equal results" do
      other = described_class.new(
        country_code: "US", country_name: "United States",
        region: "California", city: "Mountain View",
        continent_code: "NA", continent_name: "North America",
        latitude: 37.386, longitude: -122.0838,
        time_zone: "America/Los_Angeles", postal_code: "94035"
      )
      expect(result.hash).to eq(other.hash)
    end
  end
end
