# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OpenapiRailsTypedParameters::TypeGenerator do
  describe 'generate_rbs' do
    context 'Parameter types' do
      it 'generates correct types' do
        type_generator = OpenapiRailsTypedParameters::TypeGenerator.new
        actual = type_generator.generate_parameter_definitions
        expected = <<~RBS
          type get_users = {
            path_params: {
            },
            query_params: {
              role: String,
              minimum: Integer?,
              maximum: Integer?
            },
            body: __todo__,
            valid: bool
          }
        RBS

        expect(actual).to eq(type_generator.format(expected))
      end
    end

    context 'Controller actions' do
      it 'generates correct actions' do
        type_generator = OpenapiRailsTypedParameters::TypeGenerator.new
        actual = type_generator.generate_controller_definitions
        expected = <<~RBS
          class UsersController
            def self.typed_params_for: (:create) -> post_users
                                     | (:index) -> get_users
                                     | (:show) -> get_users_user_id
          end
        RBS

        expect(actual).to eq(type_generator.format(expected))
      end
    end
  end
end
