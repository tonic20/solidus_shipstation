# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusShipstation do
  describe '.config' do
    subject { described_class.config }

    specify :aggregate_failures do
      is_expected.to respond_to(:username)
      is_expected.to respond_to(:password)
      is_expected.to respond_to(:weight_units)
      is_expected.to respond_to(:ssl_encrypted)
      is_expected.to respond_to(:capture_at_notification)
    end
  end
end
