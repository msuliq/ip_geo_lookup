# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-03-30

### Fixed

- Fix CI actions

## [0.1.0] - 2026-03-30

### Added

- Pure Ruby MMDB reader - reads MaxMind's native binary format with zero external dependencies
- IPv4 and IPv6 geolocation lookup via `IpGeoLookup.lookup(ip_string)`
- `Result` with 10 fields: `country_code`, `country_name`, `region`, `city`, `continent_code`, `continent_name`, `latitude`, `longitude`, `time_zone`, `postal_code` - plus `raw` for the full MMDB record
- `Result` supports object-style (`result.city`), hash-style (`result[:city]`), `to_h`, `to_s`, `Comparable`
- `IpAddress.parse` for single-pass IP validation and integer conversion; rejects leading-zero octets (`"08.8.8.8"` returns nil)
- `IpGeoLookup.configure` for custom database path and I/O mode
- `IpGeoLookup.reload!`, `.close`, `.reset!`, `.metadata`
- Thread safety via `Mutex` for all shared state
- Two I/O modes: `:file` (default, `pread`-based, fork-friendly) and `:memory` (loads entire DB into a String)
- Support for MMDB record sizes 24, 28, and 32
- IPv4 lookups in IPv6 databases (automatic 96-bit prefix walk)
- Use-after-close protection (`ClosedError`)
- GeoLite2-City.mmdb ships with the gem - no setup, no API keys, no downloads
- CI via GitHub Actions: test matrix (Ruby 2.6, 3.0, 4.0), StandardRB linting, automated gem publishing
- Dependabot for actions and bundler dependency updates

[Unreleased]: https://github.com/msuliq/ip_geo_lookup/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/msuliq/ip_geo_lookup/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/msuliq/ip_geo_lookup/releases/tag/v0.1.0
