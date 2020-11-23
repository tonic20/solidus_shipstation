# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ShipmentTrackingLog do
  it "fallbacks to default carrier if it's not set" do
    expect(subject.carrier.name).to eq('USPS')
    subject.carrier = :UPSMI
    expect(subject.carrier.name).to eq('UPS Mail Innovations')
  end
end
