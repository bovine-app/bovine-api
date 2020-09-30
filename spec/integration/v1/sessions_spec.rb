# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'V1::Sessions', type: :request do
  with_current_user! do
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

        response '401', 'incorrect email address' do
          before { session[:session][:email] = Faker::Internet.safe_email }

          run_test!
        end

        response '401', 'incorrect password' do
          before { session[:session][:password] = Faker::Internet.password }

          run_test!
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

    path '/v1/sessions' do
      let!(:active_session) { create(:session, user: current_user) }
      let!(:expired_session) { create(:expired_session, user: current_user) }

      get 'List active sessions for the current user' do
        produces 'application/json'
        security [bearer: []]

        response '200', 'active sessions for the current user' do
          schema type: :object, required: %w[sessions], properties: {
            sessions: {
              type: :array,
              items: { '$ref': '#/components/schemas/session' }
            }
          }

          test_with_response! do |data|
            expect(data[:sessions]).to include(a_hash_including(id: current_session.id))
            expect(data[:sessions]).to include(a_hash_including(id: active_session.id))
            expect(data[:sessions]).not_to include(a_hash_including(id: expired_session.id))
          end
        end
      end
    end

    path '/v1/sessions/{id}' do
      delete 'Delete a session' do
        consumes 'application/json'
        security [bearer: []]

        parameter name: :id, in: :path, type: :string

        let(:id) { create(:session, user: current_user).id }

        response '204', 'session deleted' do
          run_test! do
            expect { Session.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        response '401', 'unauthorized' do
          let(:Authorization) { nil }

          run_test!
        end

        response '404', 'invalid session ID' do
          let(:id) { Digest::UUID.uuid_v4 }

          run_test!
        end

        response '422', 'cannot delete current session' do
          let(:id) { current_session.id }

          run_test!
        end
      end
    end
  end
end
