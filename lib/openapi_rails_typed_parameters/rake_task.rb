# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'
require 'rails'

module OpenapiRailsTypedParameters
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_writer :sig_root_dir

    def initialize(name: :openapi_rails_typed_parameters, &block)
      super()

      @name = name
      @sig_root_dir = Rails.root / 'sig/openapi_rails_typed_parameters'

      block&.call(self)

      def_generate
    end

    def def_generate
      desc 'Generate RBS files for given OpenAPI schema'
      task("#{name}:generate": :environment) do
        require 'openapi_rails_typed_parameters'

        Rails.application.eager_load!

        config = OpenapiRailsTypedParameters.configuration
        validator = OpenapiFirst.load(config.schema_path)
        validator.operations.each do |operation|
          path = Rails.application.routes.recognize_path(operation.path, method: operation.method)
          controller_name = "#{path[:controller]}_controller".camelize
          action_name = path[:action]
          rbs = <<~RBS
            class #{controller_name}
              def self.typed_params_for: (:#{action_name}) -> nil
            end
          RBS
          puts rbs
        end
      end
    end
  end
end
