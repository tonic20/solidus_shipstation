# frozen_string_literal: true

class CreateSpreeShipmentTrackingLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_shipment_tracking_logs do |t|
      t.integer :shipment_id
      t.string :carrier
      t.string :number
      t.jsonb :data

      t.timestamps
    end
    add_index :spree_shipment_tracking_logs, :shipment_id
  end
end
