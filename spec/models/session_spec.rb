# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session, type: :model do
  subject(:session) { active_session }

  let!(:active_session) { create(:session) }
  let!(:expired_session) { create(:expired_session) }

  it { is_expected.to be_valid }

  describe '.from_jwt' do
    subject { described_class.from_jwt(jwt) }

    let(:jwt) { session.to_jwt }

    it { is_expected.to have_attributes id: session.id, user_id: session.user_id }
  end

  describe '.active' do
    subject { described_class.active }

    it { is_expected.to include active_session }
    it { is_expected.not_to include expired_session }
  end

  describe '.expired' do
    subject { described_class.expired }

    it { is_expected.to include expired_session }
    it { is_expected.not_to include active_session }
  end

  describe '#expires_at' do
    subject { session.expires_at.to_s }

    before { travel_to session.created_at + 15.days }

    let(:session) { create(:session) }
    let(:now) { session.created_at + 15.days }

    it { is_expected.to eql (session.created_at + 30.days).to_s }
    it { is_expected.to eql (now + 15.days).to_s }

    context 'when updated' do
      before { session.save! }

      it { is_expected.to eql (now + 30.days).to_s }
    end
  end
end
