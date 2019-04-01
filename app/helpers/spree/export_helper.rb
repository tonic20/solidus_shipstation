require 'builder'

module Spree

  module ExportHelper

    DATE_FORMAT = '%m/%d/%Y %H:%M'.freeze

    # rubocop:disable all
    def self.address(xml, order, type)
      name = "#{type.to_s.titleize}To"
      address = order.send("#{type}_address")

      xml.__send__(name) {
        xml.Name         address.full_name
        xml.Company      address.company

        if type == :ship
          xml.Address1   address.address1
          xml.Address2   address.address2
          xml.City       address.city
          xml.State      address.state ? address.state.abbr : address.state_name
          xml.PostalCode address.zipcode
          xml.Country    address.country.iso
        end

        xml.Phone        address.phone
      }
    end
    # rubocop:enable all

    def self.pnp_product_image(variant)
      image = variant.images.first
      return image.attachment(:product) if image

      begin
        if variant.color
          color_id = variant.color.id
          image = variant.product.thumbnails_by_color(color_id).first[:display_image]
          image.attachment(:product) if image
        else
          image = variant.product.master.images.first
          image.attachment(:product) if image
        end
      rescue
        nil
      end
    end
  end

end
