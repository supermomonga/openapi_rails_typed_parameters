# frozen_string_literal: true

require 'action_controller/railtie'

class SampleApp < Rails::Application
  config.active_support.cache_format_version = 7.0
  config.logger = ActiveSupport::Logger.new($stdout)
  config.eager_load = true
  config.hosts << proc { true } if config.respond_to? :hosts
  config.root = File.dirname(__FILE__)
  config.secret_key_base = SecureRandom.uuid

  routes.append do
    resources :users
    resources :articles
  end
end

class ApplicationController < ActionController::Base
end

class UsersController < ApplicationController
  using OpenapiRailsTypedParameters

  def index
    tp = typed_parameters
    begin
      tp.validate!
      render json: tp.to_h
    rescue OpenapiFirst::RequestInvalidError => e
      render json: {
        message: e.message
      }, status: :bad_request
    end
  end

  def show
    render json: {}
  end

  def create
    render json: {}
  end

  def update
    render json: {}
  end
end

class ArticlesController < ApplicationController
  def index
    render json: []
  end

  def show
    render json: {}
  end

  def create
    render json: {}
  end

  def update
    render json: {}
  end
end

SampleApp.initialize!
