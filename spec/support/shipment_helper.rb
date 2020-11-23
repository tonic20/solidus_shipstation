# frozen_string_literal: true

module Spree
  module ShipmentHelper
    def create_shipment(options = {})
      FactoryBot.create(:shipment, options).tap do |shipment|
        shipment.update_column(:state, options[:state]) if options[:state]
      end
    end
  end
end
