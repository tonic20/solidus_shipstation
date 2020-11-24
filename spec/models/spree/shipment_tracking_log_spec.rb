# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ShipmentTrackingLog do
  it "fallbacks to default carrier if it's not set" do
    expect(subject.carrier.name).to eq('USPS')
    subject.carrier = :UPSMI
    expect(subject.carrier.name).to eq('UPS Mail Innovations')
  end

  specify '#build_tracking_url' do
    expect(subject.build_tracking_url('abc')).to match(/http.*abc.*/)
  end
end
