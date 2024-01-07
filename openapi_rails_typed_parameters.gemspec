# frozen_string_literal: true

require_relative 'lib/openapi_rails_typed_parameters/version'

Gem::Specification.new do |spec|
  spec.name = 'openapi_rails_typed_parameters'
  spec.version = OpenapiRailsTypedParameters::VERSION
  spec.authors = ['supermomonga']
  spec.email = ['hi@supermomonga.com']

  spec.summary = 'Statically typed request parameters using OpenAPI Specification'
  spec.description = 'Statically typed request parameters using OpenAPI Specification'
  spec.homepage = 'https://github.com/supermomonga/openapi_rails_typed_parameters'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.1'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md}"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .vscode .tool-versions Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'openapi_first', '~> 1.0'
  spec.add_dependency 'railties'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
