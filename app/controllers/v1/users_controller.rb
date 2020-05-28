# frozen_string_literal: true

module V1
  # User account self-management API controller.
  class UsersController < ApplicationController
    before_action :current_user, except: %i[create]

    def create
      @current_user = User.create!(user_create_params)

      pass_token(current_user.sessions.create!(
        user_agent: request.user_agent,
        created_from: request.remote_ip
      ).to_jwt)

      render status: :created, action: :show
    end

    def show; end

    def udpate; end

    def destroy; end

    private

    def pass_token(token)
      if session.empty?
        @token = token
      else
        reset_session
        session[:jwt] = token
      end
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def user_create_params
      user_params.tap do |param|
        param.require(%i[email password password_confirmation])
      end
    end
  end
end
