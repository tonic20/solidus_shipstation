# frozen_string_literal: true

module SolidusShipstation
  class Notice
    attr_reader :error, :number, :tracking, :log, :shipment
    delegate :order, to: :shipment

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @number   = params[:order_number]
      @tracking = params[:tracking_number]
      @shipment = Spree::Shipment.find_by(number: number)
      @log = prepare_log(@shipment, @number, params)
    end

    def call
      log.save!

      if _call
        log.data[:processing] = { status: :success }
        log.save!
        true
      else
        log.data[:processing] = { status: :fail, error: error }
        log.save!
        false
      end
    end

    private

    def prepare_log(shipment, number, params)
      if shipment
        record = shipment.tracking_log || shipment.build_tracking_log
        record.number = number
      else
        record = Spree::ShipmentTrackingLog.find_or_initialize_by(number: number)
      end
      record.data ||= {}
      record.data[:response] = params
      record.carrier = params[:carrier]
      record
    end

    def _call
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

    def capture_payments!
      return true if order.paid?

      # We try to capture payments if flag is set
      if SolidusShipstation.config.capture_at_notification
        process_payments!
      else
        order.errors.add(:base, 'Capture is not enabled and order is not paid')
        false
      end
    end

    def process_payments!
      order.payments.pending.each(&:capture!)
      true
    rescue Core::GatewayError => e
      order.errors.add(:base, e.message)
      false
    end

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
                      error: order.errors.full_messages.join(' '))
      SolidusShipstation.track_error(@error)
    end
  end
end
