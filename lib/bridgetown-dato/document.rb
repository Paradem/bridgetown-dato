# frozen_string_literal: true

module BridgetownDato
  class Document
    attr_accessor :raw_document

    def self.singleton!
      @singleton = true
    end

    def self.singleton?
      @singleton || false
    end

    def self.field(key, type: :markdown, path: key)
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

    def markdown(content)
      content
    end

    def timestamp(content)
      Time.parse(content)
    end
  end
end
