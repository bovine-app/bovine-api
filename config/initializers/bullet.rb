# frozen_string_literal: true

Bullet.enable = true

if Rails.env.test?
  Bullet.bullet_logger = true
  Bullet.raise = true
else
  Bullet.rails_logger = true
end
