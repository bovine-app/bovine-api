# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to be_valid }

  context 'when not saved' do
    context 'without #password' do
      before { user.password = nil }

      it { is_expected.not_to be_valid }
    end

    context 'without #password_confirmation' do
      before { user.password_confirmation = nil }

      it { is_expected.not_to be_valid }
    end
  end

  context 'when saved and found' do
    subject(:saved_user) { described_class.find(user.id) }

    before { user.save! }

    it { is_expected.to be_valid }

    context 'with only #password' do
      before { saved_user.password = Faker::Internet.password }

      it { is_expected.not_to be_valid }
    end

    context 'with only #password_confirmation' do
      before { saved_user.password_confirmation = Faker::Internet.password }

      it { is_expected.not_to be_valid }
    end

    describe '#password' do
      subject { saved_user.password }

      it { is_expected.to be_nil }
    end
  end

  # Verifies that #email is made lowercase before validation.
  context 'with case-insensitive duplicate email' do
    before { create(:user, email: user.email.upcase) }

    it { is_expected.not_to be_valid }
  end

  context 'without #email' do
    before { user.email = nil }

    it { is_expected.not_to be_valid }
  end

  # Verify that authentication works with #password_digest and #password_digest=
  # as private methods.
  describe '#authenticate' do
    subject { user.authenticate(password) }

    context 'with correct password' do
      let(:password) { user.password }

      it { is_expected.to have_attributes email: user.email }
    end

    context 'with incorrect password' do
      let(:password) { Faker::Internet.password }

      it { is_expected.to be false }
    end
  end

  describe '#password_digest' do
    subject(:digest) { user.password_digest }

    it { expect { digest }.to raise_error NoMethodError }
  end

  describe '#password_digest=' do
    subject(:digest) { user.password_digest = 'not-a-valid-bcrypt-hash' }

    it { expect { digest }.to raise_error NoMethodError }
  end

  # Verify that the user's password is not exposed in serialization of the user
  # object, without otherwise affecting the behavior of
  # ActiveModel::Serialization.serializable_hash.
  describe '#serializable_hash' do
    subject { user.serializable_hash(options) }

    let(:options) { {} }

    it { is_expected.to include 'email' => user.email }
    it { is_expected.not_to include 'password_digest' }

    context 'with additional :except fields' do
      let(:options) { { except: [:updated_at] } }

      it { is_expected.to include 'email' => user.email }
      it { is_expected.not_to include 'password_digest' }
      it { is_expected.not_to include 'updated_at' }
    end

    context 'with protected attributes in other options' do
      let(:options) { { only: [:password_digest], methods: %i[password password_confirmation] } }

      it { is_expected.not_to include 'password' }
      it { is_expected.not_to include 'password_confirmation' }
      it { is_expected.not_to include 'password_digest' }
    end
  end
end
