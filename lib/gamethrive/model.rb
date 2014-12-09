module Gamethrive

  class Model

    @@attribute_mapping = {}

    def self.attribute(name, api_name = nil)
      @@attribute_mapping[name.to_sym] = api_name || name.to_s

      define_method "#{name.to_s}=" do |value|
        write_attribute(name, value)
      end
      define_method "#{name.to_s}_changed?" do
        @_changed_attributes.include?(name.to_sym)
      end
      define_method name.to_s do
        read_attribute(name)
      end
    end

    def initialize
      reset_changed_attributes!
      reset_attributes!

      assign_attributes(attributes)
    end

    def reset_changed_attributes!
      @_changed_attributes = []
    end

    def dirty?
      not changed_attributes.empty?
    end

    def attributes_for_api
      changed_attributes.inject({}) do |hash, attr_name|
        hash[@@attribute_mapping[attr_name].to_s] = read_attribute(attr_name)
        hash
      end
    end

    protected

    def changed_attributes
      @_changed_attributes
    end

    def assign_attributes(attributes, options = {})
      options = { :reset => true }.merge(options)

      reset_attributes! if options[:reset]

      attributes.map do |name, value|
        write_attribute(name, value)
      end
    end

    def reset_attributes!
      @_attributes = {}
    end

    def write_attribute(name, value)
      name = name.to_sym
      @_attributes[name] = value
      @_changed_attributes << name
    end

    def read_attribute(name)
      @_attributes[name.to_sym]
    end

  end
end
