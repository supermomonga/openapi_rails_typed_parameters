# frozen_string_literal: true

module OpenapiRailsTypedParameters
  class TypeGenerator
    def generate_rbs
      config = OpenapiRailsTypedParameters.configuration
      validator = OpenapiFirst.load(config.schema_path)

      <<~RBS
        #{parameter_definitions(validator:)}

        #{controller_definitions(validator:)}
      RBS
    end

    private

    def operation_to_type_name(operation:)
      # TODO: sequence number for duped name
      verb = operation.method
      path =
        operation
        .path
        .scan(/[\w_]+/)
        .join('_')
      "#{verb}_#{path}_params"
    end

    def parameter_definitions(validator:)
      lines = []

      operations = validator.operations
      operations.each do |operation|
        type_name = operation_to_type_name(operation:)

        path_params_rbs =
          operation
          .query_parameters
          &.parameters
          .then { _1 || [] }
          .map do |param|
            type = param.schema['type']
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

        lines << <<~RBS
          type #{type_name} = {
            path_params: {
              #{path_params_rbs}
            },
            query_params: {
              #{query_params_rbs}
            },
            body: {
            },
            valid: bool
          }
        RBS
      end

      lines.join("\n")
    end

    def controller_definitions(validator:)
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
      params_definitions.map do |controller_name, action_definitions|
        lines << "class #{controller_name}"
        action_definitions.each.with_index do |(action_name, operation), i|
          type_name = operation_to_type_name(operation:)
          lines << if i.zero?
                     "  def self.typed_params_for: (:#{action_name}) -> #{type_name}"
                   else
                     "                           | (:#{action_name}) -> #{type_name}"
                   end
        end
        lines << 'end'
      end
      lines.join("\n")
    end
  end
end
