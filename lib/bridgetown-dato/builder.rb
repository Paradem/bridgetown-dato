# frozen_string_literal: true

require "dato/site/client"
require "dotenv"

module BridgetownDato
  class Builder < Bridgetown::Builder
    def build
      raise "Missing DatoCMS site API token!" if token.blank?

      generator do
        site.data[:dato] = klasses.reduce({}) do |hash, klass|
          hash.merge documents(klass)
        end
      end
    end

    private

    def klasses
      BridgetownDato::Document.subclasses
    end

    def documents(klass)
      type = klass.name.split("::").last.underscore
      docs = items(type)

      if klass.singleton?
        { type => klass.new(docs.first) }
      else
        { type.pluralize => docs.map { |doc| klass.new(doc) } }
      end
    end

    def items(type)
      client.items.all(nested: true, all_pages: true, filter: { type: type })
    end

    def client
      @client ||= ::Dato::Site::Client.new(token)
    end

    def token
      @token ||= if ENV["DATO_API_TOKEN"].present?
                   ENV["DATO_API_TOKEN"]
                 elsif File.exist?(".env")
                   ::Dotenv::Environment.new(".env")["DATO_API_TOKEN"]
                 end
    end
  end
end

BridgetownDato::Builder.register
