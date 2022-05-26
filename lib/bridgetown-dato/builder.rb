# frozen_string_literal: true

require "dato/site/client"
require "dato/local/loader"
require "dotenv"
require "singleton"

module BridgetownDato
  class DatoLocal
    include Singleton

    attr_accessor :data

    def loader(config)
      @loader ||= begin
        Bridgetown.logger.info("rage")
        Dato::Local::Loader.new(
          ::Dato::Site::Client.new(token),
          config[:dato_config][:preview_mode]
        )
      end
    end

    def load(config)
      loader(config)
      @data ||= @loader.load
    end

    def token
      @token ||= if ENV["DATO_API_TOKEN"].present?
                   ENV["DATO_API_TOKEN"]
                 elsif File.exist?(".env")
                   ::Dotenv::Environment.new(".env")["DATO_API_TOKEN"]
                 end
    end

    # Helpers to keep the API interface tidy
    def self.loader(config)
      instance.loader(config)
    end

    def self.load(config)
      instance.load(config)
    end

    def self.token?
      instance.token.blank?
    end

    def self.clear
      instance.data = nil
    end
  end

  class Builder < Bridgetown::Builder
    CONFIG_DEFAULTS = {
      dato_config: {
        live_reload: true,
        preview_mode: false,
      },
    }.freeze

    def build
      raise "Missing DatoCMS site API token!" if DatoLocal.token?

      generator do
        site.data[:dato] = DatoLocal.load(config)
        live_reload! if config[:dato_config][:live_reload]
      end
    end

    private

    def live_reload!
      DatoLocal.loader(config).watch do
        DatoLocal.clear
        Bridgetown::Watcher.reload_site(site, config)
      end
    end
  end
end

BridgetownDato::Builder.register
