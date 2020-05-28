# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session, type: :model do
  subject(:session) { build(:session) }

  it { is_expected.to be_valid }

  describe '.from_jwt' do
    subject { described_class.from_jwt(jwt) }

    let(:jwt) { session.to_jwt }

    before { session.save! }

    it { is_expected.to have_attributes id: session.id, user_id: session.user_id }
  end
end
