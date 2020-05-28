# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'V1::Users', type: :request do
  # header :user_agent, Faker::Internet.user_agent

  path '/v1/user' do
    post 'Create a new user' do
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            '$ref': '#/components/schemas/user',
            required: %w[email password password_confirmation]
          }
        },
        required: %w[user]
      }

      let(:base_user) { FactoryBot.build(:user) }
      let(:user) do
        { 'user' => {
          email: base_user.email,
          password: base_user.password,
          password_confirmation: base_user.password_confirmation
        } }
      end

      response '201', 'user created' do
        schema type: :object, required: %w[token user], properties: {
          token: { type: :string },
          user: {
            '$ref': '#/components/schemas/user',
            required: %w[id email created_at updated_at]
          }
        }

        run_test!
      end

      response '400', 'missing parameters' do
        before { user['user']['email'] = nil }

        run_test!
      end

      response '422', 'validation falied' do
        before do
          user['user']['password'] = user['user']['password_confirmation'] =
            Faker::Internet.password(min_length: 7, max_length: 7)
        end

        run_test!
      end
    end
  end
end
