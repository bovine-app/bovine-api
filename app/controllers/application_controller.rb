# frozen_string_literal: true

# Base controller.
class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  helper_method :current_user

  protect_from_forgery with: :null_session

  after_action :set_csrf_cookie, unless: -> { session.empty? }

  protected

  # Allow forgery protection unless it is explicitly disabled in the environment
  # configuration.
  def allow_forgery_protection
    Rails.application.config.action_controller.allow_forgery_protection != false
  end

  def current_user
    @current_user ||= jwt.user
  rescue ActiveRecord::RecordNotFound
    unauthorized
  end

  def unauthorized
    reset_session
    head :unauthorized
  end

  private

  def bearer_token
    request.authorization&.match(/\ABearer (\S+)\z/)&.captures&.first
  end

  def jwt
    @jwt ||= Session.from_jwt(session.empty? ? bearer_token : session[:jwt]).tap do |jwt|
      jwt.update!(last_accessed_from: request.remote_ip, last_accessed_at: Time.zone.now)
    end
  rescue ActiveRecord::RecordNotFound,
         JWT::DecodeError,
         JWT::ExpiredSignature,
         JWT::ImmatureSignature,
         JWT::VerificationError
    unauthorized
  end

  def set_csrf_cookie
    cookies[:csrf_token] = form_authenticity_token
  end
end
