# frozen_string_literal: true

require "dato/site/client"
require "dato/local/loader"
require "dotenv"

module BridgetownDato
  class Builder < Bridgetown::Builder
    CONFIG_DEFAULTS = {
      dato_config: {
        live_reload: true,
        preview_mode: false,
      },
    }.freeze

    def build
      raise "Missing DatoCMS site API token!" if token.blank?

      generator do
        site.data[:dato] = loader.load
        live_reload! if config[:dato_config][:live_reload]
      end
    end

    private

    def live_reload!
      loader.watch do
        Bridgetown::Watcher.reload_site(site, config)
      end
    end

    def loader
      @loader ||= Dato::Local::Loader.new(
        ::Dato::Site::Client.new(token),
        config[:dato_config][:preview_mode]
      )
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
