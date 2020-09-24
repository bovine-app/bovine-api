# frozen_string_literal: true

module V1
  # User session management API controller.
  class SessionsController < ApplicationController
    include SessionCreatable

    before_action :current_user, only: %i[index destroy]

    def index; end

    def create
      @current_user = User.find_by(email: session_create_params[:email]).authenticate(session_create_params[:password])
      create_session

      render 'v1/users/show', status: :created
    end

    def destroy
      session_id ? destroy_other_session : destroy_current_session
      head :no_content
    end

    private

    def destroy_current_session
      current_session.destroy!
      reset_session unless session.empty?
    end

    def destroy_other_session
      raise Errors::UnprocessableEntityError if session_id == current_session.id

      current_user.sessions.find(session_id).destroy!
    end

    def session_params
      @session_params ||= params.require(:session).permit(:email, :password)
    end

    def session_create_params
      @session_create_params ||= session_params.tap do |param|
        param.require(%i[email password])
      end
    end

    def session_id
      params.permit(:id)[:id]
    end
  end
end
