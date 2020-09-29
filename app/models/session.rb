# frozen_string_literal: true

# Tracks active user sessions for serialization as JWTs and user
# de/authentication.
class Session < ApplicationRecord
  JWT_ALGORITHM = 'HS256'
  JWT_DECODE_OPTS = { algorithm: JWT_ALGORITHM, nbf_leeway: 30, verify_iat: true }.freeze
  JWT_SECRET = Rails.application.credentials.secret_key_base

  belongs_to :user

  before_save :extend_life

  scope :active, -> { where(expires_at: Time.zone.now..) }
  scope :expired, -> { self.not(active) }

  class << self
    def from_jwt(jwt)
      payload, = JWT.decode(jwt, JWT_SECRET, true, JWT_DECODE_OPTS)
      active.find_by!(id: payload['jti'], user_id: payload['sub'])
    end
  end

  def as_jwt
    {
      sub: user_id,
      exp: expires_at.to_i,
      nbf: iat,
      iat: iat,
      jti: id
    }
  end

  def to_jwt
    JWT.encode(as_jwt, JWT_SECRET, JWT_ALGORITHM)
  end

  private

  def extend_life
    self.expires_at = 30.days.from_now
  end

  def iat
    @iat ||= created_at.to_i
  end

  def read_attribute_for_serialization(key)
    if %w[created_from last_accessed_from].include?(key)
      send(key).to_s
    else
      super
    end
  end
end
