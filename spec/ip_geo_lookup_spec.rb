# frozen_string_literal: true

RSpec.describe IpGeoLookup do
  let(:fixture_path) { File.join(FIXTURES_DIR, "ipv4.mmdb") }

  before(:each) do
    described_class.configure do |config|
      config.database_path = fixture_path
    end
  end

  describe ".lookup" do
    context "IPv4" do
      it "returns a Result with all fields for a known IP" do
        result = described_class.lookup("100.0.0.1")
        expect(result).to be_a(IpGeoLookup::Result)
        expect(result.country_code).to eq("AU")
        expect(result.country_name).to eq("Australia")
        expect(result.region).to eq("New South Wales")
        expect(result.city).to eq("Sydney")
        expect(result.continent_code).to eq("OC")
        expect(result.latitude).to be_within(0.001).of(-33.8688)
        expect(result.time_zone).to eq("Australia/Sydney")
        expect(result.postal_code).to eq("2000")
      end

      it "exposes the raw MMDB record" do
        result = described_class.lookup("128.0.0.1")
        expect(result.raw).to be_a(Hash)
        expect(result.raw["country"]["iso_code"]).to eq("US")
      end

      it "returns nil for an IP not in the database" do
        expect(described_class.lookup("8.8.8.8")).to be_nil
      end

      it "returns nil for invalid IPs" do
        expect(described_class.lookup("not_an_ip")).to be_nil
        expect(described_class.lookup("")).to be_nil
        expect(described_class.lookup(nil)).to be_nil
      end

      it "rejects IPs with leading zeros" do
        expect(described_class.lookup("064.0.0.1")).to be_nil
      end
    end

    context "IPv6" do
      before(:each) do
        described_class.configure do |config|
          config.database_path = File.join(FIXTURES_DIR, "ipv6.mmdb")
        end
      end

      it "returns a Result for a known IPv6 address" do
        result = described_class.lookup("2001::1")
        expect(result).to be_a(IpGeoLookup::Result)
        expect(result.country_code).to eq("DE")
        expect(result.city).to eq("Frankfurt")
      end

      it "returns a Result for a different IPv6 prefix" do
        result = described_class.lookup("2600::1")
        expect(result.country_code).to eq("US")
      end

      it "returns nil for an unknown IPv6 address" do
        expect(described_class.lookup("fe80::1")).to be_nil
      end

      it "returns nil for an invalid IPv6 address" do
        expect(described_class.lookup(":::invalid")).to be_nil
      end
    end
  end

  describe ".metadata" do
    it "returns database metadata" do
      expect(described_class.metadata).to be_a(Hash)
      expect(described_class.metadata["database_type"]).to eq("Test")
    end
  end

  describe ".configure" do
    it "raises DatabaseNotFoundError for missing file" do
      expect {
        described_class.configure do |config|
          config.database_path = "/nonexistent/path.mmdb"
        end
      }.to raise_error(IpGeoLookup::DatabaseNotFoundError)
    end

    it "uses the configured path after reload!" do
      described_class.reload!

      result = described_class.lookup("128.0.0.1")
      expect(result).to be_a(IpGeoLookup::Result)
      expect(result.country_code).to eq("US")
    end

    it "accepts mode option" do
      described_class.configure do |config|
        config.database_path = fixture_path
        config.mode = :file
      end

      result = described_class.lookup("128.0.0.1")
      expect(result.country_code).to eq("US")
    end
  end

  describe ".close" do
    it "closes the reader" do
      described_class.lookup("128.0.0.1")
      expect { described_class.close }.not_to raise_error
    end

    it "allows re-opening on next lookup" do
      described_class.close
      described_class.configure do |config|
        config.database_path = fixture_path
      end
      result = described_class.lookup("128.0.0.1")
      expect(result.country_code).to eq("US")
    end
  end

  describe ".reset!" do
    it "clears both reader and configuration" do
      described_class.reset!
      expect(described_class.configuration.instance_variable_get(:@database_path)).to be_nil
    end
  end

  describe "thread safety" do
    it "handles concurrent lookups without errors" do
      threads = 10.times.map do
        Thread.new do
          20.times { described_class.lookup("128.0.0.1") }
        end
      end
      threads.each(&:join)
    end
  end
end
