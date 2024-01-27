# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OpenapiRailsTypedParameters::TypeGenerator do
  describe 'generate_rbs' do
    context 'Parameter types' do
      it 'generates correct types' do
        OpenapiRailsTypedParameters.configure do |_config|
          # TODO
        end
        type_generator = OpenapiRailsTypedParameters::TypeGenerator.new
        actual = type_generator.generate_parameter_definitions
        expected = <<~RBS
          type get_users = {
            path_params: { },
            query_params: {
              role: String,
              minimum: Integer?,
              maximum: Integer?
            },
            body: __todo__,
            valid: bool
          }
          type post_users = {
            path_params: { },
            query_params: { },
            body: __todo__,
            valid: bool
          }
          type get_users_user_id = {
            path_params: { user_id: Integer },
            query_params: { },
            body: __todo__,
            valid: bool
          }
          type get_users_user_id_articles = {
            path_params: { user_id: Integer },
            query_params: { },
            body: __todo__,
            valid: bool
          }
          type get_users_user_id_articles_article_id = {
            path_params: { user_id: Integer, article_id: Integer },
            query_params: { },
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
