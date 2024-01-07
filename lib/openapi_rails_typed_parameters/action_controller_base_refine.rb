# frozen_string_literal: true

require 'action_controller/railtie'
require_relative 'handler'

module OpenapiRailsTypedParameters
  class TypedParameters
    attr_reader :path, :query, :body

    def initialize(path: {}, query: {}, body: {})
      @path = path
      @query = query
      @body = body
    end

    def to_h
      {
        path: path,
        query: query,
        body: body
      }
    end
  end

  refine ActionController::Base do
    def typed_parameters
      copied_request = request.dup
      validator = Handler.validator
      validator.request_validate(copied_request)
      TypedParameters.new(
        path: copied_request.env[OpenapiFirst::REQUEST],
        query: copied_request.env[OpenapiFirst::REQUEST],
        body: copied_request.env[OpenapiFirst::REQUEST]
      )
    end
  end
end
