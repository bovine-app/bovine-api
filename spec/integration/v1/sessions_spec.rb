# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'V1::Sessions', type: :request do
  let(:current_user) { create(:user) }
  let(:current_session) { create(:session, user: current_user) }

  let(:Authorization) { "Bearer #{current_session.to_jwt}" }

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

      let(:session) do
        {
          session: {
            email: current_user.email,
            password: current_user.password
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

        test_with_response! do |data|
          expect(data[:user][:id]).to eql current_user.id
        end
      end
    end

    delete 'Delete the current session' do
      consumes 'application/json'
      security [bearer: []]

      response '204', 'session deleted' do
        run_test! do
          expect { Session.find(current_session.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path '/v1/sessions/{id}' do
    delete 'Delete a session' do
      consumes 'application/json'
      security [bearer: []]

      parameter name: :id, in: :path, type: :string

      let(:session) { create(:session, user: current_user) }
      let(:id) { session.id }

      response '204', 'session deleted' do
        run_test! do
          expect { Session.find(session.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end

      response '422', 'cannot delete current session' do
        let(:id) { current_session.id }

        run_test!
      end
    end
  end
end
