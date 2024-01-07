# frozen_string_literal: true

require 'openapi_first'

module OpenapiRailsTypedParameters
  class Railtie < Rails::Railtie
    initializer 'openapi_rails_typed_parameters.initialize' do
      OpenapiRailsTypedParameters::Handler.build_validator_if_needed
    end
  end
end
