# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'users', type: :request do
  describe 'Query parameters' do
    context 'with valid query' do
      it 'returns response' do
        get '/users?role=admin&minimum=1'
        expected = {
          path_params: {},
          query_params: {
            role: 'admin',
            minimum: 1
          },
          body: nil,
          valid: true
        }
        actual = JSON.parse(response.body, symbolize_names: true)
        expect(actual).to eq expected
      end
    end

    context 'with invalid query' do
      context 'unknown enum value' do
        it 'returns error' do
          get '/users?role=foo&minimum=1'
          expected = {
            message: 'Query parameter is invalid: value at `/role` is not one of: ["admin", "maintainer"]'
          }
          actual = JSON.parse(response.body, symbolize_names: true)
          expect(actual).to eq expected
        end
      end
      context 'invalid value type' do
        it 'returns error' do
          get '/users?role=admin&minimum=foo'
          expected = {
            message: 'Query parameter is invalid: value at `/minimum` is not an integer'
          }
          actual = JSON.parse(response.body, symbolize_names: true)
          expect(actual).to eq expected
        end
      end
    end
  end
end
