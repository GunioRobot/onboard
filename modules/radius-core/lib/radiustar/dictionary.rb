module Radiustar

  class Dictionary

    include Radiustar

    DEFAULT_DICTIONARY_PATH = ::File.join(::File.dirname(__FILE__), '..', '..', 'templates', 'default.txt')

    def initialize(initial_path = nil)
      @attributes = AttributesCollection.new
      @vendors = VendorCollection.new

      read initial_path if initial_path
    end

    def read(path)
      file = File.open(path) do |f|
        current_vendor = nil
        f.each_line do |line|
        	next if line =~ /^\#/	# discard comments
        	split_line = line.split(/\s+/)
        	next if split_line == []
          case split_line.first.upcase
          when "ATTRIBUTE"
            current_vendor.nil? ? set_attr(split_line) : set_vendor_attr(current_vendor, split_line)
          when "VALUE"
            current_vendor.nil? ? set_value(split_line) : set_vendor_value(current_vendor, split_line)
          when "VENDOR"
            add_vendor(split_line)
          when "BEGIN-VENDOR"
            current_vendor = set_vendor(split_line)
          when "END-VENDOR"
            current_vendor = nil
          end
        end
      end
    end

    def find_attribute_by_name(name)
      @attributes.find_by_name(name)
    end

    def find_attribute_by_id(id)
      @attributes.find_by_id(id)
    end

    def attribute_name_defined?(name)
      !@attributes.find_by_name(name).nil?
    end

    def attribute_id_defined?(id)
      !@attributes.find_by_id(id).nil?
    end

    def vendors
      @vendors
    end

    def attributes
      @attributes
    end

    def name
      "Dictionary"
    end

    class << self

      def default
        new DEFAULT_DICTIONARY_PATH
      end

    end

    private

    def set_attr(line)
      @attributes.add(line[1], line[2], line[3])
    end

    def set_value(line)
      @attributes.find_by_name(line[1]).add_value(line[2], line[3])
    end

    def add_vendor(line)
      @vendors.add(line[2], line[1])
    end

    def set_vendor(line)
      @vendors.find_by_name(line[1])
    end

    def set_vendor_attr(vendor, line)
      vendor.add_attribute(line[1], line[2], line[3])
    end

    def set_vendor_value(vendor, line)
      vendor.find_attribute_by_name(line[1]).add_value(line[2], line[3])
    end

  end

end