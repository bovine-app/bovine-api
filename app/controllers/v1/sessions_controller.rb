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
      if session_id
        raise Errors::UnprocessableEntityError if session_id == current_session.id

        current_user.sessions.find(session_id).destroy!
      else
        current_session.destroy!
        reset_session unless session.empty?
      end

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

    def session_id
      params.permit(:id)[:id]
    end
  end
end
