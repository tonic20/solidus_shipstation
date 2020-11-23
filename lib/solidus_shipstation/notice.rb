# frozen_string_literal: true

module SolidusShipstation
  class Notice
    attr_reader :error, :number, :tracking, :shipment

    def self.call(params)
      service = new(params)
      result = service.apply
      create_log(service, params, result)
      result
    end

    def self.create_log(service, params, result)
      if service.shipment
        record = service.shipment.tracking_log || service.shipment.build_tracking_log
        record.number = service.number
      else
        record = Spree::ShipmentTrackingLog.find_or_initialize_by(number: service.number)
      end
      record.carrier = params[:carrier]

      record.data = {
        response: params.except('action', 'format', 'controller', 'SS-Password', 'SS-UserName'),
        processing: {
          status: result ? :success : :fail,
          error: service.error
        }
      }

      record.save!
    end

    def initialize(params)
      @number   = params[:order_number]
      @tracking = params[:tracking_number]
    end

    def apply
      find_shipment

      unless shipment
        log_not_found
        return false
      end

      unless capture_payments!
        log_not_paid
        return false
      end

      ship_it!
    rescue StandardError => e
      @error = I18n.t(:import_tracking_error, error: error.to_s)
      SolidusShipstation.track_error(@error, e)
      false
    end

    private

    def capture_payments!
      order = shipment.order
      return true if order.paid?

      # We try to capture payments if flag is set
      if SolidusShipstation.config.capture_at_notification
        process_payments!(order)
      else
        order.errors.add(:base, 'Capture is not enabled and order is not paid')
        false
      end
    end

    def process_payments!(order)
      order.payments.pending.each(&:capture!)
      true
    rescue Core::GatewayError => e
      order.errors.add(:base, e.message)
      false
    end

    # TODO: add documentation
    # => <Shipment>
    def find_shipment
      @shipment = Spree::Shipment.find_by(number: number)
    end

    # TODO: add documentation
    # => true
    def ship_it!
      shipment.update_attribute(:tracking, tracking)

      unless shipment.shipped?
        shipment.reload.ship!
        shipment.touch(:shipped_at)
        shipment.order.update!
      end

      true
    end

    def log_not_found
      @error = I18n.t(:shipment_not_found, number: number)
      SolidusShipstation.track_error(@error)
    end

    def log_not_paid
      @error = I18n.t(:capture_payment_error,
                      number: number,
                      error: shipment.order.errors.full_messages.join(' '))
      SolidusShipstation.track_error(@error)
    end
  end
end
