# frozen_string_literal: true

require 'action_controller/railtie'
require_relative 'handler'

module OpenapiRailsTypedParameters
  class TypedParameters
    attr_reader :request

    delegate :body, to: :request
    delegate :validate, to: :request
    delegate :validate!, to: :request

    def initialize(request:)
      @request = request
    end

    def path_params = request.path_parameters&.with_indifferent_access
    def query_params = request.query_parameters&.with_indifferent_access
    def valid? = validate.nil?

    def to_h
      {
        path_params:,
        query_params:,
        body:,
        valid: valid?
      }.with_indifferent_access
    end
  end

  refine ActionController::Base do
    def typed_params
      @typed_params ||= TypedParameters.new(
        request: Handler.validator.request(request)
      )
    end

    def typed_params_for(_action) = typed_params
  end
end
