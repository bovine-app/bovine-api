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

    delete 'Delete the current session' do
      consumes 'application/json'
      security [bearer: []]

      let(:current_user) { create(:user) }
      let(:session) do
        current_user.sessions.create!(
          created_from: Faker::Internet.public_ip_v4_address,
          user_agent: Faker::Internet.user_agent
        )
      end

      let(:Authorization) { "Bearer #{session.to_jwt}" }

      response '204', 'session deleted' do
        run_test! do
          expect { Session.find(session.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
