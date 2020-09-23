# frozen_string_literal: true

module V1
  # User session management API controller.
  class SessionsController < ApplicationController
    include SessionCreatable

    before_action :current_user, only: %i[destroy]

    def create
      @current_user = User.find_by(email: session_create_params[:email]).authenticate(session_create_params[:password])
      create_session

      render 'v1/users/show', status: :created
    end

    def destroy
      current_session.destroy!
      reset_session unless session.empty?

      head :no_content
    end

    private

    def session_params
      @session_params ||= params.require(:session).permit(:email, :password)
    end

    def session_create_params
      @session_create_params ||= session_params.tap do |param|
        param.require(%i[email password])
      end
    end
  end
end
