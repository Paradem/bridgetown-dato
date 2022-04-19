# frozen_string_literal: true

require "bridgetown-dato/schema"

module BridgetownDato
  class Model
    attr_accessor :raw_model

    def self.model_name
      name.split("::").last.underscore
    end

    def self.fields
      BridgetownDato::Schema.fields(model_name)
    end

    def self.field(key, map: nil, path: key)
      BridgetownDato::Schema.add_field(model_name, key)

      define_method key do
        content = raw_model.dig(*[path].flatten)
        map_content(content, map)
      end
    end

    def self.dato_name!(name)
      @dato_name = name
    end

    def self.dato_name
      @dato_name || model_name
    end

    def initialize(raw_model)
      self.raw_model = raw_model.to_hash
    end

    def to_h
      @to_h ||= self.class.fields.reduce({}) do |hash, field|
        hash.merge(field => send(field))
      end
    end

    def map_content(content, map)
      return content if map.blank?

      return map.call(content) if map.respond_to?(:call)
      return send(map, content) if respond_to?(map)
      return content.send(map) if content.respond_to?(map)

      content
    end
  end
end
