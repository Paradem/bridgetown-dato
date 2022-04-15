# frozen_string_literal: true

module BridgetownDato
  class Document
    attr_accessor :raw_document

    def self.model
      name.split("::").last.underscore
    end

    def self.singleton!
      @singleton = true
    end

    def self.singleton?
      @singleton || false
    end

    def self.schema
      @@schema ||= Hash.new([]) # rubocop:disable Style/ClassVars
    end

    def self.fields
      schema[model]
    end

    def self.add_field(key)
      fields << key
    end

    def self.field(key, type: :markdown, path: key)
      add_field(key)

      define_method key do
        content = raw_document.dig(*[path].flatten)

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

    def initialize(raw_document)
      self.raw_document = raw_document
    end

    def to_h
      @to_h ||= self.class.fields.reduce({}) do |hash, field|
        hash.merge(field => send(field))
      end
    end

    def markdown(content)
      content
    end

    def timestamp(content)
      Time.parse(content)
    end
  end
end
