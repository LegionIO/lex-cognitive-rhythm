# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_rhythm/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-rhythm'
  spec.version       = Legion::Extensions::CognitiveRhythm::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Cognitive rhythm modelling for LegionIO'
  spec.description   = 'Ultradian and circadian cognitive rhythm engine for LegionIO — ' \
                       'models attention peaks, energy troughs, and creative windows'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-rhythm'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/master/README.md"
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']   = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']
end
