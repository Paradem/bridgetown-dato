# frozen_string_literal: true

require "dato/site/client"
require "dotenv"

require "bridgetown-dato/model"

module BridgetownDato
  class Builder < Bridgetown::Builder
    def build
      raise "Missing DatoCMS site API token!" if token.blank?

      generator do
        site.data[:dato] = klasses.reduce({}) do |hash, klass|
          hash.merge models(klass)
        end
      end
    end

    private

    def klasses
      BridgetownDato::Model.subclasses
    end

    def models(klass)
      docs = items(klass.model_name)

      if klass.singleton?
        { klass.model_name => klass.new(docs.first).to_h }
      else
        { klass.model_name.pluralize => docs.map { |doc| klass.new(doc).to_h } }
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
