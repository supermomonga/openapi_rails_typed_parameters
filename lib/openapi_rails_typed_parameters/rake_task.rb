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

      define_generate_task
    end

    def define_generate_task
      desc 'Generate RBS files for given OpenAPI schema'
      task("#{name}:generate": :environment) do
        require 'openapi_rails_typed_parameters'
        type_generator = OpenapiRailsTypedParameters::TypeGenerator.new
        type_generator.generate_rbs(rbs_file_path: '')
      end
    end
  end
end
