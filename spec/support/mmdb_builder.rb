# frozen_string_literal: true

# Builds valid MMDB binary files for testing.
module MMDBBuilder
  METADATA_MARKER = "\xAB\xCD\xEFMaxMind.com".b.freeze

  module_function

  def write(path, records:, ip_version: 4, record_size: 24)
    require "fileutils"
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, build(records: records, ip_version: ip_version, record_size: record_size))
  end

  def build(records:, ip_version: 4, record_size: 24)
    bit_count = (ip_version == 6) ? 128 : 32

    data_section = "".b
    data_offsets = {}
    records.each do |cidr, record|
      data_offsets[cidr] = data_section.bytesize
      data_section << encode(record)
    end

    node_count, tree_bytes = build_tree(records.keys, data_offsets, record_size, bit_count, ip_version)

    metadata = {
      "binary_format_major_version" => 2, "binary_format_minor_version" => 0,
      "build_epoch" => 0, "database_type" => "Test",
      "description" => {"en" => "Test database"},
      "ip_version" => ip_version, "node_count" => node_count,
      "record_size" => record_size, "languages" => ["en"]
    }

    tree_bytes + ("\x00".b * 16) + data_section + METADATA_MARKER + encode(metadata)
  end

  def build_tree(cidrs, data_offsets, record_size, bit_count, ip_version)
    nodes = [[nil, nil]]

    cidrs.each do |cidr|
      ip_int, prefix_len = parse_cidr(cidr, ip_version)
      node_idx = 0

      prefix_len.times do |i|
        bit = (ip_int >> (bit_count - 1 - i)) & 1
        if i == prefix_len - 1
          nodes[node_idx][bit] = {data: data_offsets[cidr]}
        else
          child = nodes[node_idx][bit]
          if child.nil?
            new_idx = nodes.length
            nodes << [nil, nil]
            nodes[node_idx][bit] = new_idx
            node_idx = new_idx
          elsif child.is_a?(Integer)
            node_idx = child
          end
        end
      end
    end

    node_count = nodes.length
    tree_bytes = "".b
    nodes.each do |left, right|
      tree_bytes << pack_node(resolve_child(left, node_count), resolve_child(right, node_count), record_size)
    end
    [node_count, tree_bytes]
  end

  def parse_cidr(cidr, ip_version)
    ip_str, prefix_str = cidr.split("/")
    ip_int = (ip_version == 6 || ip_str.include?(":")) ? ipv6_to_int(ip_str) : ipv4_to_int(ip_str)
    [ip_int, prefix_str.to_i]
  end

  def ipv4_to_int(s)
    o = s.split(".").map(&:to_i)
    (o[0] << 24) | (o[1] << 16) | (o[2] << 8) | o[3]
  end

  def ipv6_to_int(s)
    a = s.downcase
    if a.include?("::")
      l, r = a.split("::", -1)
      lg = l.empty? ? [] : l.split(":")
      rg = r.empty? ? [] : r.split(":")
      groups = lg + Array.new(8 - lg.length - rg.length, "0") + rg
    else
      groups = a.split(":")
    end
    result = 0
    groups.each { |g| result = (result << 16) | g.to_i(16) }
    result
  end

  def resolve_child(child, node_count)
    case child
    when nil then node_count
    when Integer then child
    when Hash then child[:data] + node_count + 16
    end
  end

  def pack_node(left, right, record_size)
    case record_size
    when 24
      [left >> 16, (left >> 8) & 0xFF, left & 0xFF,
        right >> 16, (right >> 8) & 0xFF, right & 0xFF].pack("C6")
    when 28
      middle = ((left >> 24) & 0x0F) << 4 | ((right >> 24) & 0x0F)
      [(left >> 16) & 0xFF, (left >> 8) & 0xFF, left & 0xFF,
        middle,
        (right >> 16) & 0xFF, (right >> 8) & 0xFF, right & 0xFF].pack("C7")
    when 32
      [left, right].pack("NN")
    end
  end

  def encode(value)
    case value
    when Hash then encode_map(value)
    when Array then encode_array(value)
    when String then encode_string(value)
    when Integer then encode_integer(value)
    when Float then encode_double(value)
    when true then encode_ctrl(14, 1)
    when false then encode_ctrl(14, 0)
    when nil then "".b
    end
  end

  def encode_map(hash)
    buf = encode_ctrl(7, hash.size)
    hash.each { |k, v| buf << encode_string(k.to_s) << encode(v) }
    buf
  end

  def encode_array(arr)
    buf = encode_ctrl(11, arr.size)
    arr.each { |v| buf << encode(v) }
    buf
  end

  def encode_string(str)
    bytes = str.encode("UTF-8").b
    encode_ctrl(2, bytes.bytesize) + bytes
  end

  def encode_integer(value)
    bytes = uint_bytes(value)
    type = if value.between?(0, 0xFFFF) then 5
    elsif value.between?(0, 0xFFFFFFFF) then 6
    else 9
    end
    encode_ctrl(type, bytes.bytesize) + bytes
  end

  def encode_double(value)
    encode_ctrl(3, 8) + [value].pack("G")
  end

  def encode_ctrl(type, size)
    size_bits, size_ext = encode_size(size)
    if type <= 7
      [(type << 5) | size_bits].pack("C") + size_ext
    else
      [(0 << 5) | size_bits, type - 7].pack("CC") + size_ext
    end
  end

  def encode_size(size)
    if size < 29
      [size, "".b]
    elsif size < 285
      [29, [size - 29].pack("C")]
    elsif size < 65_821
      [30, [size - 285].pack("n")]
    else
      val = size - 65_821
      [31, [(val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF].pack("CCC")]
    end
  end

  def uint_bytes(value)
    return "".b if value == 0
    bytes = []
    v = value
    while v > 0
      bytes.unshift(v & 0xFF)
      v >>= 8
    end
    bytes.pack("C*")
  end
end
