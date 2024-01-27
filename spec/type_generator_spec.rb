# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OpenapiRailsTypedParameters::TypeGenerator do
  describe 'generate_rbs' do
    context 'a' do
      it 'generates correct RBS file' do
        type_generator = OpenapiRailsTypedParameters::TypeGenerator.new
        actual = type_generator.generate_rbs
        expected = <<~RBS
          class UsersController
            def self.typed_params_for: (:index) -> nil
          end
        RBS

        expect(actual).to eq(expected)
      end
    end
  end
end
