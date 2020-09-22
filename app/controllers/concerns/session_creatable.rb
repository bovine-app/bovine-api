# frozen_string_literal: true

# Create new sessions for the current user and set the token, either in the
# response or in the session.
module SessionCreatable
  extend ActiveSupport::Concern

  protected

  def create_session
    pass_token(current_user.sessions.create!(
      user_agent: request.user_agent,
      created_from: request.remote_ip
    ).to_jwt)
  end

  private

  def pass_token(token)
    if session.empty?
      @token = token
    else
      reset_session
      session[:jwt] = token
    end
  end
end
