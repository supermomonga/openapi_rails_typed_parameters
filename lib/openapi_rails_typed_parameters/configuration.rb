# frozen_string_literal: true

module OpenapiRailsTypedParameters
  class Configuration
    attr_accessor :schema_path

    def initialize
      @schema_path = Rails.root.join('schema.yml')
    end
  end

  class << self
    def configuration
      @@configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
