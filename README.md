# IpGeoLookup

A lightweight, **zero-dependency** Ruby gem for resolving IPv4 and IPv6 addresses to geographic locations. Ships with an embedded [MaxMind GeoLite2](https://dev.maxmind.com/geoip/geolite2-free-geolite2-databases) database and a pure Ruby MMDB reader - no external gems, no API keys, no setup.

## Features

- **Zero dependencies** - pure Ruby MMDB reader, no native extensions, no external gems
- **IPv4 and IPv6** - resolves to country, region, city, coordinates, timezone, and more
- **Batteries included** - GeoLite2 City database ships with the gem
- **Fast** - binary trie traversal over MaxMind's MMDB format
- **Secure** - no `Marshal.load`, rejects ambiguous IP octets with leading zeros
- **Thread-safe** - safe for Puma, Sidekiq, and other multi-threaded servers
- **Fork-friendly** - `:file` mode uses `pread` for shared OS page cache across workers
- **Configurable** - use the embedded database or point to your own `.mmdb` file

## Installation

```ruby
gem "ip_geo_lookup"
```

```sh
bundle install
```

That's it - the database is included.

## Usage

### Basic lookup

```ruby
require "ip_geo_lookup"

result = IpGeoLookup.lookup("8.8.8.8")
result = IpGeoLookup.lookup("2001:4860:4860::8888")
```

### Accessing results

```ruby
result = IpGeoLookup.lookup("8.8.8.8")

# Core fields
result.country_code  # => "US"
result.country_name  # => "United States"
result.region        # => "California"
result.city          # => "Mountain View"

# Extended fields
result.continent_code  # => "NA"
result.continent_name  # => "North America"
result.latitude        # => 37.386
result.longitude       # => -122.0838
result.time_zone       # => "America/Los_Angeles"
result.postal_code     # => "94035"

# Hash-style access
result[:country_code]  # => "US"

# Full MMDB record
result.raw  # => {"country" => {"iso_code" => "US", ...}, ...}

# Conversions
result.to_h  # => {country_code: "US", country_name: "United States", ...}
result.to_s  # => "Mountain View, California, United States (US)"

# Sorting
results = ips.map { |ip| IpGeoLookup.lookup(ip) }.compact.sort
```

### Handling unknown IPs

Returns `nil` when the IP address is not found or is invalid:

```ruby
IpGeoLookup.lookup("192.168.1.1")  # => nil  (private range)
IpGeoLookup.lookup("not_an_ip")    # => nil  (invalid format)
IpGeoLookup.lookup("08.8.8.8")     # => nil  (leading zeros rejected)
IpGeoLookup.lookup(nil)            # => nil
```

### Configuration

```ruby
IpGeoLookup.configure do |config|
  config.database_path = "/path/to/GeoLite2-City.mmdb"
  config.mode = :memory  # optional: load entire DB into memory for single-process apps
end
```

### Lifecycle

```ruby
IpGeoLookup.reload!   # re-reads from disk, respects configured path
IpGeoLookup.close     # releases file handle / memory
IpGeoLookup.metadata  # => {"database_type" => "GeoLite2-City", ...}
```

## How It Works

The gem includes a pure Ruby reader for MaxMind's [MMDB binary format](https://maxmind.github.io/MaxMind-DB/). On lookup:

1. The IP string is validated and converted to an integer in a single pass
2. The MMDB binary trie is walked (32 bits for IPv4, 128 for IPv6)
3. The matching record is decoded from the data section
4. A `Result` object is returned (or `nil` if no match)

Two I/O modes are available:

- **`:file`** (default) - keeps the file open and uses `IO#pread` for reads; the OS page cache shares data across forked workers automatically
- **`:memory`** - reads the entire file into a Ruby String for fastest lookups in single-process environments

## Compatibility

- Ruby >= 2.6.0
- Zero external dependencies
- Thread-safe
- Linux, macOS, Windows

## Development

```sh
bundle install
bundle exec rake spec
```

Test fixtures are generated automatically during the test run - no external database file needed.

### Updating the MaxMind database

The embedded GeoLite2 City database lives in `data/GeoLite2-City.mmdb` (gitignored due to size). To update it:

1. Create a free account at [MaxMind](https://www.maxmind.com/en/geolite2/signup)
2. Download the GeoLite2 City MMDB file
3. Copy it into the gem:
   ```sh
   cp /path/to/GeoLite2-City.mmdb data/GeoLite2-City.mmdb
   ```
4. Rebuild the gem: `gem build ip_geo_lookup.gemspec`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Available as open source under the [MIT License](LICENSE).

## Attribution

This product includes GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com).
