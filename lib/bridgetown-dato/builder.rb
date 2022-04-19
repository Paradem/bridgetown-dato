# frozen_string_literal: true

require "dato/site/client"
require "dato/local/loader"
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
      if collections.respond_to?(klass.dato_name.pluralize)
        items = collections.send(klass.dato_name.pluralize)
        { klass.model_name.pluralize => items.map { |item| klass.new(item).to_h } }
      elsif collections.respond_to?(klass.dato_name)
        item = collections.send(klass.dato_name)
        { klass.model_name => klass.new(item).to_h }
      end
    end

    def collections
      @collections ||= Dato::Local::Loader.new(
        ::Dato::Site::Client.new(token),
        false
      ).load
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
