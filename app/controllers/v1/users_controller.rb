# frozen_string_literal: true

module V1
  # User account self-management API controller.
  class UsersController < ApplicationController
    before_action :current_user, except: %i[create]
    before_action :require_current_password, only: %i[update destroy]

    def create
      @current_user = User.create!(user_create_params)

      pass_token(current_user.sessions.create!(
        user_agent: request.user_agent,
        created_from: request.remote_ip
      ).to_jwt)

      render status: :created, action: :show
    end

    def show; end

    def update
      current_user.update!(user_params)

      render action: :show
    end

    def destroy; end

    private

    def current_password
      params.require(:current_password)
    end

    def pass_token(token)
      if session.empty?
        @token = token
      else
        reset_session
        session[:jwt] = token
      end
    end

    def require_current_password
      raise Errors::ForbiddenError unless current_user.authenticate(current_password)
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
