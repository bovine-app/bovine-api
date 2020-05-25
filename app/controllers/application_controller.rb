# frozen_string_literal: true

# Base controller.
class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :null_session

  after_action :set_csrf_cookie, unless: -> { session.empty? }

  protected

  # Allow forgery protection unless it is explicitly disabled in the environment
  # configuration.
  def allow_forgery_protection
    Rails.application.config.action_controller.allow_forgery_protection != false
  end

  private

  def set_csrf_cookie
    cookies[:csrf_token] = form_authenticity_token
  end
end
