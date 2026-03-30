# frozen_string_literal: true

module IpGeoLookup
  # Pure Ruby reader for MaxMind's MMDB binary format.
  class MMDB
    MODE_MEMORY = :memory
    MODE_FILE = :file

    METADATA_MARKER = "\xAB\xCD\xEFMaxMind.com".b.freeze

    attr_reader :metadata

    def initialize(path, mode: MODE_MEMORY)
      raise DatabaseNotFoundError, "Database file not found: #{path}" unless File.exist?(path)

      @closed = false

      case mode
      when MODE_MEMORY
        @data = File.binread(path)
        @use_file = false
      when MODE_FILE
        @io = File.open(path, "rb")
        @file_size = @io.size
        @use_file = true
        @has_pread = @io.respond_to?(:pread)
        @file_mutex = Mutex.new unless @has_pread
      else
        raise ArgumentError, "Unknown mode: #{mode}. Use :memory or :file"
      end

      load_metadata
    end

    # Returns the MMDB record Hash for the given IP integer, or nil.
    def find(ip_int, bit_count)
      raise ClosedError, "Reader is closed" if @closed

      if bit_count == 32 && @ip_version == 6
        start = ipv4_start_node
        return nil if start >= @node_count
        search_tree(ip_int, 32, start)
      elsif bit_count == 128 && @ip_version == 4
        nil
      else
        search_tree(ip_int, bit_count, 0)
      end
    end

    def close
      @closed = true
      if @use_file
        @io&.close
        @io = nil
      else
        @data = nil
      end
    end

    private

    def read_bytes(offset, length)
      if @use_file
        if @has_pread
          @io.pread(length, offset)
        else
          @file_mutex.synchronize {
            @io.seek(offset)
            @io.read(length)
          }
        end
      else
        @data.byteslice(offset, length)
      end
    end

    # --- Metadata ---

    def load_metadata
      size = @use_file ? @file_size : @data.bytesize
      search_size = [size, 131_072].min
      chunk = read_bytes(size - search_size, search_size)
      pos = chunk.rindex(METADATA_MARKER)
      raise DatabaseFormatError, "MMDB metadata marker not found" unless pos

      meta_offset = (size - search_size) + pos + METADATA_MARKER.bytesize
      @metadata, _ = decode(meta_offset)
      raise DatabaseFormatError, "Invalid metadata" unless @metadata.is_a?(Hash)

      @node_count = @metadata["node_count"] || raise(DatabaseFormatError, "Missing node_count")
      @record_size = @metadata["record_size"] || raise(DatabaseFormatError, "Missing record_size")
      @ip_version = @metadata["ip_version"] || raise(DatabaseFormatError, "Missing ip_version")

      unless [24, 28, 32].include?(@record_size)
        raise DatabaseFormatError, "Unsupported record size: #{@record_size}"
      end

      @node_byte_size = @record_size / 4
      @search_tree_size = @node_count * @node_byte_size
      @data_section_offset = @search_tree_size + 16
    end

    # --- Search tree ---

    def ipv4_start_node
      @ipv4_start_node ||= begin
        node = 0
        96.times do
          break if node >= @node_count
          node, _ = read_node(node)
        end
        node
      end
    end

    def search_tree(ip_int, bit_count, start_node)
      node = start_node

      bit_count.times do |i|
        left, right = read_node(node)
        record = (((ip_int >> (bit_count - 1 - i)) & 1) == 0) ? left : right

        if record < @node_count
          node = record
        elsif record == @node_count
          return nil
        else
          value, _ = decode(@search_tree_size + record - @node_count)
          return value
        end
      end

      nil
    end

    # Reads one node in a single I/O call, returns [left, right].
    def read_node(node_number)
      buf = read_bytes(node_number * @node_byte_size, @node_byte_size)

      case @record_size
      when 24
        left = (buf.getbyte(0) << 16) | (buf.getbyte(1) << 8) | buf.getbyte(2)
        right = (buf.getbyte(3) << 16) | (buf.getbyte(4) << 8) | buf.getbyte(5)
      when 28
        mid = buf.getbyte(3)
        left = ((mid >> 4) << 24) |
          (buf.getbyte(0) << 16) | (buf.getbyte(1) << 8) | buf.getbyte(2)
        right = ((mid & 0x0F) << 24) |
          (buf.getbyte(4) << 16) | (buf.getbyte(5) << 8) | buf.getbyte(6)
      when 32
        left, right = buf.unpack("NN")
      end

      [left, right]
    end

    # --- Data decoder ---

    def decode(offset)
      ctrl = read_bytes(offset, 1).getbyte(0)
      offset += 1

      type = (ctrl >> 5) & 7
      if type == 0
        type = read_bytes(offset, 1).getbyte(0) + 7
        offset += 1
      end

      return decode_pointer(ctrl, offset) if type == 1

      size, offset = read_payload_size(ctrl, offset)

      case type
      when 2 then [read_bytes(offset, size).force_encoding("UTF-8"), offset + size]
      when 3 then [read_bytes(offset, 8).unpack1("G"), offset + 8]
      when 4 then [read_bytes(offset, size), offset + size]
      when 5, 6, 9, 10 then decode_uint(size, offset)
      when 7 then decode_map(size, offset)
      when 8 then decode_int32(size, offset)
      when 11 then decode_array(size, offset)
      when 14 then [size != 0, offset]
      when 15 then [read_bytes(offset, 4).unpack1("g"), offset + 4]
      else raise DatabaseFormatError, "Unknown MMDB data type: #{type}"
      end
    end

    def read_payload_size(ctrl, offset)
      size = ctrl & 0x1F
      if size < 29
        [size, offset]
      elsif size == 29
        [29 + read_bytes(offset, 1).getbyte(0), offset + 1]
      elsif size == 30
        buf = read_bytes(offset, 2)
        [285 + ((buf.getbyte(0) << 8) | buf.getbyte(1)), offset + 2]
      else
        buf = read_bytes(offset, 3)
        [65_821 + ((buf.getbyte(0) << 16) | (buf.getbyte(1) << 8) | buf.getbyte(2)), offset + 3]
      end
    end

    def decode_pointer(ctrl, offset)
      ptr_size = (ctrl >> 3) & 3

      case ptr_size
      when 0
        ptr = ((ctrl & 7) << 8) | read_bytes(offset, 1).getbyte(0)
        offset += 1
      when 1
        buf = read_bytes(offset, 2)
        ptr = (((ctrl & 7) << 16) | (buf.getbyte(0) << 8) | buf.getbyte(1)) + 2048
        offset += 2
      when 2
        buf = read_bytes(offset, 3)
        ptr = (((ctrl & 7) << 24) | (buf.getbyte(0) << 16) | (buf.getbyte(1) << 8) | buf.getbyte(2)) + 526_336
        offset += 3
      when 3
        buf = read_bytes(offset, 4)
        ptr = (buf.getbyte(0) << 24) | (buf.getbyte(1) << 16) | (buf.getbyte(2) << 8) | buf.getbyte(3)
        offset += 4
      end

      value, _ = decode(@data_section_offset + ptr)
      [value, offset]
    end

    def decode_uint(size, offset)
      return [0, offset] if size == 0
      buf = read_bytes(offset, size)
      val = 0
      size.times { |i| val = (val << 8) | buf.getbyte(i) }
      [val, offset + size]
    end

    def decode_map(size, offset)
      map = {}
      size.times do
        key, offset = decode(offset)
        val, offset = decode(offset)
        map[key] = val
      end
      [map, offset]
    end

    def decode_array(size, offset)
      arr = []
      size.times do
        val, offset = decode(offset)
        arr << val
      end
      [arr, offset]
    end

    def decode_int32(size, offset)
      val, offset = decode_uint(size, offset)
      val -= (1 << 32) if val >= (1 << 31)
      [val, offset]
    end
  end

  class DatabaseNotFoundError < StandardError; end
  class DatabaseFormatError < StandardError; end
  class ClosedError < StandardError; end
end
