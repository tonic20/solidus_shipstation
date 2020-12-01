# frozen_string_literal: true

require 'spec_helper'

describe SolidusShipstation::Notice do
  context 'capture at notification is true' do
    before do
      SolidusShipstation.config.capture_at_notification = true
    end

    context 'successful capture' do
      it 'payments are completed' do
        order = create(:completed_order_with_pending_payment)
        notice = define_shipment_notice(order)
        expect(notice.call).to eq(true)

        order.reload.shipments.each do |shipment|
          expect(shipment).to be_shipped
        end
        order.payments.each do |payment|
          expect(payment.reload).to be_completed
        end
        expect(order).to be_paid
      end
    end

    context 'capture fails' do
      it "doesn't ship the shipment" do
        order = create(:completed_order_with_pending_payment)
        notice = define_shipment_notice(order)

        expect_any_instance_of(Spree::Payment).to receive(:capture!).and_raise(Spree::Core::GatewayError)
        expect(notice.call).to eq(false)

        order.reload.shipments.each do |shipment|
          expect(shipment).not_to be_shipped
        end
        order.payments.each do |payment|
          expect(payment.reload).not_to be_completed
        end
        expect(order).not_to be_paid
      end
    end
  end

  context 'capture at notification is false' do
    before do
      SolidusShipstation.config.capture_at_notification = false
    end

    context 'order is not paid' do
      it "doesn't ship the shipment" do
        order = create(:completed_order_with_pending_payment)
        notice = define_shipment_notice(order)

        expect(notice.call).to eq(false)

        order.reload.shipments.each do |shipment|
          expect(shipment).not_to be_shipped
        end
        order.payments.each do |payment|
          expect(payment.reload).not_to be_completed
        end
        expect(order).not_to be_paid
        expect(notice.error).to be_present
      end
    end
  end

  describe '#call' do
    let(:order_number) { 'S12345' }
    let(:tracking_number) { '1Z1231234' }
    let(:order) { instance_double(Spree::Order, paid?: true) }
    let(:tracking_log) { Spree::ShipmentTrackingLog.new }
    let(:shipment) { instance_double(Spree::Shipment, order: order, tracking_log: tracking_log, shipped?: false, pending?: false) }
    let(:notice) do
      described_class.new(order_number: order_number,
                          tracking_number: tracking_number)
    end

    context 'shipment found' do
      before do
        expect(Spree::Shipment).to receive(:find_by).with(number: order_number).and_return(shipment)
      end

      context 'transition succeeds' do
        before do
          expect(shipment).to receive(:update_attribute).with(:tracking, tracking_number)
          expect(shipment).to receive_message_chain(:reload, :ship!)
          expect(shipment).to receive(:touch).with(:shipped_at)
          expect(order).to receive(:update!)
          expect(tracking_log).to receive(:save!).twice
        end

        it 'returns true' do
          expect(notice.call).to eq(true)
        end
      end

      context 'transition fails' do
        before do
          expect(shipment).to receive(:update_attribute).with(:tracking, tracking_number)
          expect(shipment).to receive_message_chain(:reload, :ship!).and_raise('oopsie')
          expect(Rails.logger).to receive(:error)
          @result = notice.call
        end

        it 'returns false and sets @error', :aggregate_failures do
          expect(@result).to eq(false)
          expect(notice.error).to be_present
        end
      end
    end

    context 'shipment not found' do
      before do
        expect(Spree::Shipment).to receive(:find_by).with(number: order_number).and_return(nil)
        expect(Rails.logger).to receive(:error)
      end

      it '#call returns false and sets @error', :aggregate_failures do
        expect(notice.call).to eq(false)
        expect(notice.error).to be_present
      end
    end
  end

  context 'shipment already shipped' do
    it 'updates #tracking and returns true' do
      tracking_number = 'ZN10110'
      order = create(:shipped_order)
      notice = define_shipment_notice(order, tracking_number)

      expect(notice.call).to eq(true)
      expect(order.reload.shipments.first.tracking).to eq(tracking_number)
    end

    it 'does not update #state' do
      order = create(:shipped_order)
      notice = define_shipment_notice(order)
      expect { notice.call }.not_to change { order.shipments.first.state }
    end
  end

  def define_shipment_notice(order, tracking_number = '1Z1231234')
    described_class.new(order_number: order.shipments.first.number,
                        tracking_number: tracking_number)
  end
end
