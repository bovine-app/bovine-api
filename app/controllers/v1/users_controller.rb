# frozen_string_literal: true

module V1
  # User account self-management API controller.
  class UsersController < ApplicationController
    include SessionCreatable

    before_action :current_user, except: %i[create]
    before_action :require_current_password, only: %i[update destroy]

    def create
      @current_user = User.create!(user_create_params)
      create_session

      render status: :created, action: :show
    end

    def show; end

    def update
      current_user.update!(user_params)

      render action: :show
    end

    def destroy
      current_user.destroy!

      head :no_content
    end

    private

    def current_password
      params.require(:current_password)
    end

    def require_current_password
      raise Errors::ForbiddenError unless current_user.authenticate(current_password)
    end

    def user_params
      @user_params ||= params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def user_create_params
      @user_create_params ||= user_params.tap do |param|
        param.require(%i[email password password_confirmation])
      end
    end
  end
end
