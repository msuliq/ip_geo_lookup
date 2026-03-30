# frozen_string_literal: true

module IpGeoLookup
  module IpAddress
    module_function

    # Returns [integer, version] or nil. Rejects leading-zero octets.
    def parse(ip_string)
      return nil unless ip_string.is_a?(String)

      addr = ip_string.strip
      if addr.include?(":")
        int = to_i_v6(addr)
        int ? [int, 6] : nil
      elsif addr.include?(".")
        int = to_i(addr)
        int ? [int, 4] : nil
      end
    end

    # IPv4 string to 32-bit integer. Rejects leading-zero octets.
    def to_i(ip_string)
      return nil unless ip_string.is_a?(String)

      octets = ip_string.strip.split(".")
      return nil unless octets.length == 4

      result = 0
      octets.each do |octet|
        return nil unless octet.match?(/\A(0|[1-9]\d{0,2})\z/)
        value = octet.to_i
        return nil if value > 255
        result = (result << 8) | value
      end
      result
    end

    # IPv6 string to 128-bit integer. Supports :: shorthand.
    def to_i_v6(ip_string)
      return nil unless ip_string.is_a?(String)

      addr = ip_string.strip.downcase
      return nil if addr.empty? || addr.include?("%")

      if addr.include?("::")
        return nil if addr.scan("::").length > 1

        left, right = addr.split("::", -1)
        left_groups = left.empty? ? [] : left.split(":")
        right_groups = right.empty? ? [] : right.split(":")
        fill_count = 8 - left_groups.length - right_groups.length
        return nil if fill_count < 0

        groups = left_groups + Array.new(fill_count, "0") + right_groups
      else
        groups = addr.split(":")
      end

      return nil unless groups.length == 8

      result = 0
      groups.each do |group|
        return nil unless group.match?(/\A[0-9a-f]{1,4}\z/)
        result = (result << 16) | group.to_i(16)
      end
      result
    end
  end
end
