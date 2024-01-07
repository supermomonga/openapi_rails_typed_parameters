# frozen_string_literal: true

require_relative 'configuration'

module OpenapiRailsTypedParameters
  class Handler
    class << self
      attr_accessor :configuration, :validator
    end

    def self.build_validator
      config = OpenapiRailsTypedParameters.configuration
      self.validator = OpenapiFirst.load(config.schema_path)
      validator
    end

    def self.build_validator_if_needed
      validator || build_validator
    end
  end
end
