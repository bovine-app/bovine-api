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

      let(:base_user) { build(:user) }
      let(:user) do
        {
          user: {
            email: base_user.email,
            password: base_user.password,
            password_confirmation: base_user.password_confirmation
          }
        }
      end

      response '201', 'user created' do
        schema type: :object, required: %w[token user], properties: {
          token: { type: :string },
          user: {
            '$ref': '#/components/schemas/user',
            required: %w[id email created_at updated_at]
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body).with_indifferent_access
          expect(User.find(data[:user][:id]).email).to eql base_user.email
        end
      end

      response '400', 'missing parameters' do
        schema type: :object, required: %w[message parameter], properties: {
          message: { type: :string },
          parameter: { type: :string }
        }

        before { user[:user][:email] = nil }

        run_test!
      end

      response '422', 'validation falied' do
        schema '$ref': '#/components/schemas/validationErrors'

        before do
          user[:user][:password] = user[:user][:password_confirmation] =
            Faker::Internet.password(min_length: 7, max_length: 7)
        end

        run_test!
      end
    end

    get 'Get the current user' do
      produces 'application/json'
      security [bearer: []]

      let(:user) { create(:user) }

      response '200', 'current user' do
        schema type: :object, required: %w[user], properties: {
          user: { '$ref': '#/components/schemas/user' }
        }

        let(:Authorization) do
          session = user.sessions.create!(
            created_from: Faker::Internet.public_ip_v4_address,
            user_agent: Faker::Internet.user_agent
          )
          "Bearer #{session.to_jwt}"
        end

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end
    end

    put 'Update the current user' do
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            '$ref': '#/components/schemas/user',
            required: %w[email password password_confirmation]
          },
          current_password: { type: :string }
        },
        required: %w[user current_password]
      }

      let(:current_user) { create(:user) }

      let(:Authorization) do
        session = current_user.sessions.create!(
          created_from: Faker::Internet.public_ip_v4_address,
          user_agent: Faker::Internet.user_agent
        )
        "Bearer #{session.to_jwt}"
      end

      let(:email) { Faker::Internet.safe_email }

      let(:user) do
        {
          current_password: current_user.password,
          user: {
            email: email
          }
        }
      end

      response '200', 'user updated' do
        schema type: :object, required: %w[user], properties: {
          user: {
            '$ref': '#/components/schemas/user',
            required: %w[id email created_at updated_at]
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body).with_indifferent_access
          expect(data[:user][:email]).to eql email
          expect(User.find(current_user.id).email).to eql email
        end
      end

      response '400', 'missing parameters' do
        schema type: :object, required: %w[message parameter], properties: {
          message: { type: :string },
          parameter: { type: :string }
        }

        before { user[:current_password] = nil }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end

      response '403', 'forbidden' do
        before { user[:current_password] = Faker::Internet.password }

        run_test!
      end

      response '422', 'validation falied' do
        schema '$ref': '#/components/schemas/validationErrors'

        before do
          user[:user][:password] = user[:user][:password_confirmation] =
            Faker::Internet.password(min_length: 7, max_length: 7)
        end

        run_test!
      end
    end

    delete 'Delete the current user' do
      consumes 'application/json'
      security [bearer: []]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          current_password: { type: :string }
        },
        required: %w[current_password]
      }

      let(:current_user) { create(:user) }

      let(:Authorization) do
        session = current_user.sessions.create!(
          created_from: Faker::Internet.public_ip_v4_address,
          user_agent: Faker::Internet.user_agent
        )
        "Bearer #{session.to_jwt}"
      end

      let(:user) do
        {
          current_password: current_user.password
        }
      end

      response '204', 'user deleted' do
        run_test! do
          expect { User.find(current_user.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      response '400', 'missing parameters' do
        schema type: :object, required: %w[message parameter], properties: {
          message: { type: :string },
          parameter: { type: :string }
        }

        before { user[:current_password] = nil }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end

      response '403', 'forbidden' do
        before { user[:current_password] = Faker::Internet.password }

        run_test!
      end
    end
  end
end
