# frozen_string_literal: true

# An individual user account.
class User < ApplicationRecord
  PROTECTED_ATTRIBUTES = %i[password password_confirmation password_digest].freeze

  has_secure_password

  has_many :sessions, dependent: :delete_all

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8, allow_nil: true }, presence: { if: :password_confirmation }
  validates :password_confirmation, presence: { if: :password }

  before_validation :downcase_email

  # Protect the user's password from being exposed in serialization of the user
  # object.
  def serializable_hash(options = {})
    (options[:except] ||= []).push(*PROTECTED_ATTRIBUTES).uniq!
    %i[methods only].each { |opt| reject_protected_attributes options[opt] }

    super
  end

  private

  # Downcase the user's email address before validation to avoid the cost of
  # performing a case-insensitive database query during uniqueness validation.
  # Technically the local-part of an email address is case-sensitive, but in
  # practice it's rarely treated as such by email servers. It's more likely and
  # otherwise impractical to protect against a user inadvertantly creating a
  # duplicate account with email addresses that differ only in case, when their
  # email provider treats them as the same address, compared to needing to
  # support distinct uses with email addresses that differ only in case.
  def downcase_email
    email&.downcase!
  end

  def password_digest
    super
  end

  def password_digest=(val)
    super
  end

  def reject_protected_attributes(array)
    array&.reject! { |val| PROTECTED_ATTRIBUTES.include?(val) }
  end
end
