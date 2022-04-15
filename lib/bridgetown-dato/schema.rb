# frozen_string_literal: true

module BridgetownDato
  class Schema
    def self.schema
      @schema ||= Hash.new([])
    end

    def self.models
      schema.keys
    end

    def self.fields(model)
      schema[model]
    end

    def self.add_field(model, field)
      schema[model] = [] unless schema.key? model
      schema[model] << field unless field.in? schema[model]
    end
  end
end
