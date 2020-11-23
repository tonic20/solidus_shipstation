# frozen_string_literal: true

Spree::Shipment.class_eval do
  has_one :tracking_log, class_name: '::Spree::ShipmentTrackingLog'

  def shipping_method_name
    tracking_log&.shipping_method || selected_shipping_rate.name
  end

  def tracking_url
    return unless tracking && shipping_method

    @tracking_url ||= (tracking_log || shipping_method).build_tracking_url(tracking)
  end
end
