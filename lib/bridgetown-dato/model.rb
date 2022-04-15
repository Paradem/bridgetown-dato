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

    def self.singleton!
      @singleton = true
    end

    def self.singleton?
      @singleton || false
    end

    def self.field(key, type: :markdown, path: key)
      BridgetownDato::Schema.add_field(model_name, key)

      define_method key do
        content = raw_model.dig(*[path].flatten)

        if respond_to? type
          send(type, content)
        else
          content
        end
      end
    end

    field :meta_created_at, path: %w[meta created_at]
    field :meta_current_version, path: %w[meta current_version]
    field :meta_first_published_at, path: %w[meta first_published_at]
    field :meta_is_valid, path: %w[meta is_valid]
    field :meta_publication_scheduled_at, path: %w[meta publication_scheduled_at]
    field :meta_published_at, path: %w[meta published_at]
    field :meta_status, path: %w[meta status]
    field :meta_unpublishing_scheduled_at, path: %w[meta unpublishing_scheduled_at]
    field :meta_updated_at, path: %w[meta updated_at]

    def initialize(raw_model)
      self.raw_model = raw_model
    end

    def to_h
      @to_h ||= self.class.fields.reduce({}) do |hash, field|
        hash.merge(field => send(field))
      end
    end

    def markdown(content)
      content
    end
  end
end
