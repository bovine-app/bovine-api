# frozen_string_literal: true

# Base controller.
class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  helper_method :current_session, :current_user

  protect_from_forgery with: :null_session

  after_action :set_csrf_cookie, unless: -> { session.empty? }

  rescue_from ActionController::ParameterMissing, with: :rescue_parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :rescue_record_invalid
  rescue_from HTTP::Errors::BaseError, with: :rescue_http_error

  protected

  # Allow forgery protection unless it is explicitly disabled in the environment
  # configuration.
  def allow_forgery_protection
    Rails.application.config.action_controller.allow_forgery_protection != false
  end

  def current_session
    @current_session ||= Session.from_jwt(jwt).tap do |sess|
      sess.update!(last_accessed_from: request.remote_ip, last_accessed_at: Time.zone.now)
    end
  rescue ActiveRecord::RecordNotFound,
         JWT::DecodeError,
         JWT::ExpiredSignature,
         JWT::ImmatureSignature,
         JWT::VerificationError
    raise HTTP::Errors::UnauthorizedError
  end

  def current_user
    @current_user ||= current_session.user
  rescue ActiveRecord::RecordNotFound
    raise HTTP::Errors::UnauthorizedError
  end

  private

  def bearer_token
    request.authorization&.match(/\ABearer (\S+)\z/)&.captures&.first
  end

  def jwt
    @jwt ||= session.empty? ? bearer_token : session[:jwt]
  end

  def rescue_parameter_missing(exception)
    render status: :bad_request, json: {
      message: 'Parameter Missing',
      parameter: exception.param
    }
  end

  def rescue_record_invalid(exception)
    render status: :unprocessable_entity, json: {
      message: 'Validation Failed',
      errors: exception.record.errors.details.map do |field, details|
        {
          field: field,
          details: details
        }
      end
    }
  end

  def rescue_http_error(exception)
    exception.handle(self)
    head exception.code
  end

  def set_csrf_cookie
    cookies[:csrf_token] = form_authenticity_token
  end
end
