# frozen_string_literal: true

Spree::Carton.class_eval do
  def shipping_method_name
    tracking_log&.shipping_method || shipping_method.name
  end

  def tracking_url
    return unless tracking && shipping_method

    @tracking_url ||= (tracking_log || shipping_method).build_tracking_url(tracking)
  end

  def tracking_log
    return @tracking_log if defined?(@tracking_log)
    @tracking_log = shipments.first.tracking_log
  end
end
