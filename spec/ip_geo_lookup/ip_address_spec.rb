# frozen_string_literal: true

RSpec.describe IpGeoLookup::IpAddress do
  describe ".parse" do
    it "returns [integer, 4] for valid IPv4" do
      expect(described_class.parse("8.8.8.8")).to eq([134744072, 4])
    end

    it "returns [integer, 6] for valid IPv6" do
      expect(described_class.parse("::1")).to eq([1, 6])
    end

    it "strips whitespace" do
      expect(described_class.parse("  8.8.8.8  ")).to eq([134744072, 4])
    end

    it "returns nil for invalid IPv4" do
      expect(described_class.parse("08.8.8.8")).to be_nil
      expect(described_class.parse("not_an_ip")).to be_nil
    end

    it "returns nil for invalid IPv6" do
      expect(described_class.parse(":::invalid")).to be_nil
    end

    it "returns nil for non-string input" do
      expect(described_class.parse(nil)).to be_nil
      expect(described_class.parse(123)).to be_nil
    end

    it "returns nil for empty string" do
      expect(described_class.parse("")).to be_nil
    end
  end

  describe ".to_i" do
    it "converts 0.0.0.0 to 0" do
      expect(described_class.to_i("0.0.0.0")).to eq(0)
    end

    it "converts 255.255.255.255 to max 32-bit value" do
      expect(described_class.to_i("255.255.255.255")).to eq(4294967295)
    end

    it "converts 8.8.8.8 correctly" do
      expect(described_class.to_i("8.8.8.8")).to eq(134744072)
    end

    it "converts 1.0.0.0 correctly" do
      expect(described_class.to_i("1.0.0.0")).to eq(16777216)
    end

    it "handles leading/trailing whitespace" do
      expect(described_class.to_i("  8.8.8.8  ")).to eq(134744072)
    end

    it "returns nil for non-string input" do
      expect(described_class.to_i(nil)).to be_nil
      expect(described_class.to_i(123)).to be_nil
    end

    it "returns nil for invalid IPs" do
      expect(described_class.to_i("")).to be_nil
      expect(described_class.to_i("not_an_ip")).to be_nil
      expect(described_class.to_i("1.2.3")).to be_nil
      expect(described_class.to_i("1.2.3.4.5")).to be_nil
      expect(described_class.to_i("256.0.0.0")).to be_nil
      expect(described_class.to_i("1.2.3.-1")).to be_nil
      expect(described_class.to_i("1.2.3.abc")).to be_nil
    end

    it "rejects octets with leading zeros" do
      expect(described_class.to_i("08.8.8.8")).to be_nil
      expect(described_class.to_i("8.08.8.8")).to be_nil
      expect(described_class.to_i("01.02.03.04")).to be_nil
      expect(described_class.to_i("010.0.0.1")).to be_nil
      expect(described_class.to_i("1.2.3.00")).to be_nil
    end

    it "accepts single zero octets" do
      expect(described_class.to_i("0.0.0.0")).to eq(0)
      expect(described_class.to_i("10.0.0.1")).to eq(167772161)
    end
  end

  describe ".to_i_v6" do
    it "converts full notation" do
      result = described_class.to_i_v6("2001:0db8:0000:0000:0000:0000:0000:0001")
      expect(result).to eq(42540766411282592856903984951653826561)
    end

    it "converts :: shorthand for loopback" do
      expect(described_class.to_i_v6("::1")).to eq(1)
    end

    it "converts :: shorthand for all zeros" do
      expect(described_class.to_i_v6("::")).to eq(0)
    end

    it "converts compressed notation" do
      result = described_class.to_i_v6("2001:db8::1")
      expect(result).to eq(42540766411282592856903984951653826561)
    end

    it "converts Google DNS IPv6" do
      result = described_class.to_i_v6("2001:4860:4860::8888")
      expect(result).to be_a(Integer)
      expect(result).to be > 0
    end

    it "handles uppercase" do
      result = described_class.to_i_v6("2001:DB8::1")
      expect(result).to eq(42540766411282592856903984951653826561)
    end

    it "handles leading/trailing whitespace" do
      expect(described_class.to_i_v6("  ::1  ")).to eq(1)
    end

    it "returns nil for non-string input" do
      expect(described_class.to_i_v6(nil)).to be_nil
      expect(described_class.to_i_v6(123)).to be_nil
    end

    it "returns nil for invalid IPv6 addresses" do
      expect(described_class.to_i_v6("")).to be_nil
      expect(described_class.to_i_v6("not_ipv6")).to be_nil
      expect(described_class.to_i_v6("2001:db8::1::2")).to be_nil
      expect(described_class.to_i_v6("2001:db8:gggg::1")).to be_nil
    end

    it "rejects zone IDs" do
      expect(described_class.to_i_v6("fe80::1%eth0")).to be_nil
    end
  end
end
