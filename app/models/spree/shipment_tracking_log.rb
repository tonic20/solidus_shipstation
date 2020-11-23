# frozen_string_literal: true

module Spree
  class ShipmentTrackingLog < ApplicationRecord
    Carrier = Struct.new(:name, :tracking_url) do
      def build_tracking_url(*args, &block)
        ShippingMethod.instance_method(:build_tracking_url).bind(self).call(*args, &block)
      end
    end

    belongs_to :shipment, optional: true
    delegate :build_tracking_url, to: :carrier

    def carrier
      return @_carrier if @_carrier

      data = SolidusShipstation.config.carriers[super]
      data ||= SolidusShipstation.config.carriers[SolidusShipstation.config.default_carrier]
      @_carrier = Carrier.new(data[:name], data[:tracking_url])
    end

    def carrier=(value)
      remove_instance_variable(:@_carrier) if defined?(@_carrier)
      super
    end

    def shipping_method
      carrier.name
    end
  end
end
