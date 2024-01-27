# frozen_string_literal: true

require 'rbs'

module OpenapiRailsTypedParameters
  class TypeGenerator
    private attr_accessor :config
    private attr_accessor :validator

    def initialize
      @config = OpenapiRailsTypedParameters.configuration
      @validator = OpenapiFirst.load(@config.schema_path)
    end

    def generate_rbs
      rbs = <<~RBS
        #{generate_parameter_definitions}
        #{generate_controller_definitions}
      RBS
      return format(rbs)
    end

    def operation_to_type_name(operation:)
      # TODO: Use same naming as Rails path helper
      verb = operation.method
      path =
        operation
        .path
        .scan(/[\w_]+/)
        .join('_')
      return "#{verb}_#{path}"
    end

    def generate_parameter_definitions
      definitions = []

      operations = validator.operations
      operations.each do |operation|
        type_name = operation_to_type_name(operation:)

        path_params_rbs =
          operation
          .path_parameters
          &.parameters
          .then { _1 || [] }
          .map do |param|
            type = param.schema['type'].camelize
            optional = param.required? ? '' : '?'
            "#{param.name}: #{type}#{optional}"
          end
          .join(",\n")

        query_params_rbs =
          operation
          .query_parameters
          &.parameters
          .then { _1 || [] }
          .map do |param|
            type = param.schema['type'].camelize
            optional = param.required? ? '' : '?'
            "#{param.name}: #{type}#{optional}"
          end
          .join(",\n")

        definitions << <<~RBS
          type #{type_name} = {
            path_params: { #{path_params_rbs} },
            query_params: { #{query_params_rbs} },
            body: __todo__,
            valid: bool
          }
        RBS
      end

      # return 'type hoge = {hi: Integer}'
      rbs = format(definitions.join("\n"))
      return rbs
    end

    def generate_controller_definitions
      Rails.application.eager_load!
      route_inspector = ActionDispatch::Routing::RoutesInspector.new(Rails.application.routes.routes)
      journy_routes = route_inspector.instance_variable_get(:@routes)

      # @type var params_definitions: Hash[String, Hash[String, untyped]]
      params_definitions = {}
      validator.operations.each do |operation|
        puts "Find: #{operation.method} #{operation.path}"
        path = journy_routes.find do |route|
          route.path.match?(operation.path) && route.verb.downcase.to_sym == operation.method.to_sym
        end

        # path not found
        next unless path

        controller_name = "#{path.defaults[:controller]}_controller".camelize
        action_name = path.defaults[:action]

        params_definitions[controller_name] ||= {}
        params_definitions[controller_name][action_name] = operation
      end

      lines = []
      params_definitions
        .sort_by { |controller_name, _| controller_name }
        .map do |controller_name, action_definitions|
          lines << "class #{controller_name}"
          action_definitions
            .sort_by { |action_name, _| action_name }
            .each.with_index do |(action_name, operation), i|
            type_name = operation_to_type_name(operation:)
            lines << if i.zero?
                       "  def self.typed_params_for: (:#{action_name}) -> #{type_name}"
                     else
                       "                           | (:#{action_name}) -> #{type_name}"
                     end
          end
          lines << 'end'
        end
      return format(lines.join("\n"))
    end

    def format(rbs)
      signature = RBS::Parser.parse_signature(rbs)
      stream = StringIO.new
      writer = RBS::Writer.new(out: stream)
      writer.write(signature[1] + signature[2])
      formatted = stream.string
      stream.close
      return formatted
    end
  end
end
