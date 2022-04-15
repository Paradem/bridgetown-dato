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

    def self.field(key, map: nil, path: key, localized: false)
      BridgetownDato::Schema.add_field(model_name, key)

      define_method key do
        content = raw_model.dig(*[path].flatten)
        map_field(content, map, localized)
      end
    end

    def self.meta_fields!
      field :meta_created_at, path: %w[meta created_at]
      field :meta_current_version, path: %w[meta current_version]
      field :meta_first_published_at, path: %w[meta first_published_at]
      field :meta_is_valid, path: %w[meta is_valid]
      field :meta_publication_scheduled_at, path: %w[meta publication_scheduled_at]
      field :meta_published_at, path: %w[meta published_at]
      field :meta_status, path: %w[meta status]
      field :meta_unpublishing_scheduled_at, path: %w[meta unpublishing_scheduled_at]
      field :meta_updated_at, path: %w[meta updated_at]
    end

    def self.singleton!
      @singleton = true
    end

    def self.singleton?
      @singleton || false
    end

    def self.dato_name!(name)
      @dato_name = name
    end

    def self.dato_name
      @dato_name || model_name
    end

    def initialize(raw_model)
      self.raw_model = raw_model
    end

    def to_h
      @to_h ||= self.class.fields.reduce({}) do |hash, field|
        hash.merge(field => send(field))
      end
    end

    def map_field(content, map, localized)
      if localized
        content.map { |k, v| [k, map_localized_content(k, v, map)] }.to_h
      else
        map_content(content, map)
      end
    end

    def map_localized_content(lang, content, map)
      return content if map.blank?

      return map.call(content, lang) if map.respond_to?(:call)
      return send(map, content, lang) if respond_to?(map)
      return content.send(map) if content.respond_to?(map)

      content
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
