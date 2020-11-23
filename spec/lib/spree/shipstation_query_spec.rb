# frozen_string_literal: true

require 'spec_helper'

describe Spree::ShipstationQuery do
  context 'shipment_decorator methods' do
    describe '.between' do
      let(:now) { Time.now.utc }

      let!(:order1) { create(:order) }
      let!(:order2) { create(:order) }
      let!(:order3) { create(:order) }
      let!(:yesterday) { create_shipment(order: order2) }
      let!(:tomorrow) { create_shipment(order: order2) }
      let!(:old_shipment_recent_order_update) { create_shipment(created_at: now - 1.week, order: order3) }
      let!(:active1) { create_shipment }
      let!(:active2) { create_shipment }
      let(:query) { described_class.between(now - 1.hour, now + 1.hour) }

      # Use Timecop set #updated_at at specific times rather than manually settting them
      #   as ActiveRecord will automatically set #updated_at timestamps even when attempting to
      #   override them for Spree::Order instances
      before do
        Timecop.freeze(now - 1.day) do
          order1.touch
          yesterday.touch
        end

        Timecop.freeze(now + 1.day) do
          order2.touch
          tomorrow.touch
        end

        Timecop.freeze(now - 1.week) do
          order3.touch
        end
      end

      it 'returns shipments based on shipments/orders updated_at within the given time range', :aggregate_failures do
        expect(query.count).to eq(3)
        expect(query).to match_array([old_shipment_recent_order_update, active1, active2])
      end
    end

    describe '.exportable' do
      def create_complete_order
        FactoryBot.create(:order, state: 'complete', completed_at: Time.zone.now)
      end

      let!(:incomplete_order) { create(:order, state: 'confirm') }
      let!(:incomplete) do
        create_shipment(state: 'pending',
                        order: incomplete_order)
      end
      let!(:pending) do
        create_shipment(state: 'pending',
                        order: create_complete_order)
      end
      let!(:ready) do
        create_shipment(state: 'ready',
                        order: create_complete_order)
      end
      let!(:shipped) do
        create_shipment(state: 'shipped',
                        order: create_complete_order)
      end
      let!(:canceled) do
        create_shipment(state: 'canceled',
                        order: create_complete_order)
      end

      let(:query) { described_class.exportable }

      context 'when capture at notification is false' do
        before { SolidusShipstation.config.capture_at_notification = false }

        it 'has the expected shipment instances', :aggregate_failures do
          expect(query.count).to eq(1)
          expect(query).to eq([ready])
          expect(query).not_to include(pending)
          expect(query).not_to include(incomplete)
        end
      end

      context 'when capture at notification is true' do
        before { SolidusShipstation.config.capture_at_notification = true }

        it 'has the expected shipment instances', :aggregate_failures do
          expect(query.count).to eq(3)
          expect(query).to match_array([pending, ready, shipped])
          expect(query).not_to include(incomplete)
        end
      end
    end
  end
end
