# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'a', type: :request do
  it 'returns an object' do
    get '/users?role=admin&minimum=1'
    expected = []
    expect(response.body).to eq expected
  end
end
