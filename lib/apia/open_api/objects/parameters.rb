# frozen_string_literal: true

# Parameters describe the arguments that can be passed to an endpoint via the query string.
# We only declare these for GET requests, otherwise we define a request body.
#
# "parameters": [
#   {
#     "name": "data_center[id]",
#     "in": "query",
#     "schema": {
#       "type": "string"
#     }
#   },
#   {
#     "name": "data_center[permalink]",
#     "in": "query",
#     "schema": {
#       "type": "string"
#     }
#   }
# ]
module Apia
  module OpenApi
    module Objects
      class Parameters

        include Apia::OpenApi::Helpers

        def initialize(spec:, argument:, route_spec:)
          @spec = spec
          @argument = argument
          @route_spec = route_spec
        end

        def add_to_spec
          if @argument.type.argument_set?
            generate_argument_set_params
          elsif @argument.array?
            if @argument.type.enum? || @argument.type.object?
              items = generate_schema_ref(@argument)
            else
              items = generate_scalar_schema(@argument)
            end

            param = {
              name: "#{@argument.name}[]",
              in: "query",
              schema: {
                type: "array",
                items: items
              }
            }
            param[:description] = @argument.description if @argument.description.present?
            param[:required] = true if @argument.required?
            add_to_parameters(param)
          elsif @argument.type.enum?
            param = {
              name: @argument.name.to_s,
              in: "query",
              schema: generate_schema_ref(@argument)
            }
            param[:description] = @argument.description if @argument.description.present?
            param[:required] = true if @argument.required?
            add_to_parameters(param)
          else
            param = {
              name: @argument.name.to_s,
              in: "query",
              schema: generate_scalar_schema(@argument)
            }
            param[:description] = @argument.description if @argument.description.present?
            param[:required] = true if @argument.required?
            add_to_parameters(param)
          end
        end

        private

        # Complex argument sets are not supported in query params (e.g. nested objects)
        # For any LookupArgumentSet only one argument is expected to be provided.
        # However, OpenAPI does not currently support describing mutually exclusive query params.
        # refer to: https://swagger.io/docs/specification/describing-parameters/#dependencies
        def generate_argument_set_params
          @argument.type.klass.definition.arguments.each_value do |child_arg|
            param = {
              name: "#{@argument.name}[#{child_arg.name}]",
              in: "query",
              schema: generate_scalar_schema(child_arg)
            }
            description = []
            description << formatted_description(@argument.description) if @argument.description.present?
            description << formatted_description(child_arg.description) if child_arg.description.present?
            description << "All '#{@argument.name}[]' params are mutually exclusive, only one can be provided."
            param[:description] = description.join(" ")
            add_to_parameters(param)
          end
        end

        def add_to_parameters(param)
          @route_spec[:parameters] << param
        end

      end
    end
  end
end
