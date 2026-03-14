# frozen_string_literal: true

require 'legion/extensions/cognitive_rhythm/version'
require 'legion/extensions/cognitive_rhythm/helpers/constants'
require 'legion/extensions/cognitive_rhythm/helpers/rhythm'
require 'legion/extensions/cognitive_rhythm/helpers/rhythm_engine'
require 'legion/extensions/cognitive_rhythm/runners/cognitive_rhythm'
require 'legion/extensions/cognitive_rhythm/client'

module Legion
  module Extensions
    module Helpers
      module Lex; end
    end
  end
end

module Legion
  module Logging
    def self.method_missing(*); end
    def self.respond_to_missing?(*) = true
  end
end
