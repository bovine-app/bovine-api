# frozen_string_literal: true

require 'rails_helper'

# Helpers for RSwag example groups.
module SwaggerGroupHelpers
  def with_current_user!
    create_user_with_session!

    let(:Authorization) { "Bearer #{current_session.to_jwt}" }

    yield if block_given?
  end

  def test_with_response!(&block)
    submit_request!

    it "returns a #{metadata[:response][:code]} response" do |example|
      assert_response_matches_metadata(metadata, &block)
      parse_data_and_call(example, &block)
    end
  end

  private

  def create_user_with_session!
    let(:current_user) { create(:user) }
    let(:current_session) { create(:session, user: current_user) }
  end

  def submit_request!
    let(:metadata) { |example| example.metadata }

    before { submit_request(metadata) }
  end
end

# Helpers for RSwag examples.
module SwaggerExampleHelpers
  def parse_data_and_call(example, &block)
    data = JSON.parse(response.body).with_indifferent_access
    example.instance_exec(data, &block) if block_given?
  end
end

RSpec.configure do |config|
  config.extend SwaggerGroupHelpers
  config.include SwaggerExampleHelpers

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Bovine API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :string, readOnly: true },
              created_at: { type: :string, readOnly: true },
              updated_at: { type: :string, readOnly: true },
              email: { type: :string },
              password: { type: :string, writeOnly: true },
              password_confirmation: { type: :string, writeOnly: true }
            }
          },
          validationErrors: {
            type: :object,
            required: %w[message errors],
            properties: {
              message: { type: :string },
              errors: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    field: { type: :string },
                    details: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          error: { type: :string }
                        },
                        required: %w[error]
                      }
                    }
                  },
                  required: %w[field details]
                }
              }
            }
          }
        },
        securitySchemes: {
          bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        }
      },
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
