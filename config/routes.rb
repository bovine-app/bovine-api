# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  defaults format: :json do
    namespace :v1 do
      resource :session, only: %i[create destroy]
      resources :sessions, only: %i[destroy]
      resource :user
    end
  end
end
