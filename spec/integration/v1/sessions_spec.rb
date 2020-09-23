# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'V1::Sessions', type: :request do
  path '/v1/session' do
    post 'Create a new session' do
      consumes 'application/json'
      produces 'application/json'

      parameter name: :session, in: :body, schema: {
        type: :object,
        properties: {
          session: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            },
            required: %w[email password]
          }
        },
        required: %w[session]
      }

      let(:user) { create(:user) }
      let(:session) do
        {
          session: {
            email: user.email,
            password: user.password
          }
        }
      end

      response '201', 'session created' do
        schema type: :object, required: %w[token user], properties: {
          token: { type: :string },
          user: {
            '$ref': '#/components/schemas/user',
            required: %w[id email created_at updated_at]
          }
        }

        run_test!
      end
    end
  end
end
