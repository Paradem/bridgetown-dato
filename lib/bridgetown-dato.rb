# frozen_string_literal: true

require "bridgetown"
require "bridgetown-dato/builder"
require "bridgetown-dato/model"
require "bridgetown-dato/schema"

Bridgetown::PluginManager.new_source_manifest(
  origin: BridgetownDato
)
