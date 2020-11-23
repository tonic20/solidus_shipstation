# frozen_string_literal: true

module Spree
  module ShipstationQuery
    module_function

    def export(start_date, end_date, page)
      exportable.merge(between(start_date, end_date)).page(page).per(50)
    end

    def exportable
      query = Shipment.order(:updated_at).joins(:order).merge(Order.complete).where.not(spree_shipments: { state: 'canceled' })
      query = query.ready unless SolidusShipstation.config.capture_at_notification
      query
    end

    def between(from, to)
      Shipment.joins(:order).where(
        '(spree_shipments.updated_at > :from AND spree_shipments.updated_at < :to) OR
        (spree_orders.updated_at > :from AND spree_orders.updated_at < :to)',
        from: from, to: to
      )
    end
  end
end
