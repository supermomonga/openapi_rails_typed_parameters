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
        rbs = type_generator.generate_rbs
        file_path = File.join(@sig_root_dir, 'action_controller.rbs')

        options = parse_options(argv: ARGV)

        if File.exist?(file_path) && options[:force] == false
          abort "RBS file '#{file_path}' already exists. use `--force` option to overwrite."
        else
          File.write(file_path, rbs)
        end
      end
    end

    private

    def parse_options(argv:)
      options = {}

      option_parser = OptionParser.new
      option_parser.banner = 'Usage: openapi_rails_typed_parameters:generate [options]'
      option_parser.on('-f', '--force', FalseClass, 'Force overwrite RBS file if it\'s already exists.')
      args = option_parser.order(argv)
      option_parser.parse(args, into: options)

      options
    end
  end
end
