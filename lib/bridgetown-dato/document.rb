# frozen_string_literal: true

module BridgetownDato
  class Document
    attr_accessor :raw_document

    def self.field(key, type = :text)
      define_method key do
        if respond_to? type
          send(type, raw_document[key])
        else
          raw_document[key]
        end
      end
    end

    def initialize(raw_document)
      self.raw_document = raw_document
    end

    def text(content)
      content
    end

    def timestamp(content)
      Time.parse(content)
    end
  end
end
