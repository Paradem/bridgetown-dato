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
