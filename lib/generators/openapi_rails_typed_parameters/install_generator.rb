# frozen_string_literal: true

require 'rails'

module OpenapiRailsTypedParameters
  class InstallGenerator < Rails::Generators::Base
    create_file 'lib/tasks/openapi_rails_typed_parameters.rake', <<~RUBY
      begin
        require 'openapi_rails_typed_parameters/rake_task'

        OpenapiRailsTypedParameters::RakeTask.new do |task|
          # Base path for RBS generation.
          # default: Rails.root / 'sig/openapi_rails_typed_parameters'
          # task.sig_root_dir = Rails.root / 'sig/openapi_rails_typed_parameters'
        end
      rescue LoadError
        # failed to load openapi_rails_typed_parameters. Skip to load openapi_rails_typed_parameters tasks.
      end
    RUBY
  end
end
