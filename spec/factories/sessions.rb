# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    user
    user_agent { Faker::Internet.user_agent }
    created_from { Faker::Internet.ip_v4_address }
  end
end
