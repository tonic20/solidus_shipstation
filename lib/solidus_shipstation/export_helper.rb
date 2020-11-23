# frozen_string_literal: true

require 'builder'

module SolidusShipstation
  module ExportHelper
    module_function

    DATE_FORMAT = '%m/%d/%Y %H:%M'

    def address(xml, order, type)
      name = "#{type.to_s.titleize}To"
      address = order.send("#{type}_address")

      xml.tag!(name) do
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

        xml.Phone address.phone
      end
    end

    def product_image_with_fallback(variant)
      variant_image(variant) || variant_image(variant.product.master)
    end

    def variant_image(variant)
      variant.images.first&.attachment(:product)
    end

    def to_date_str(date)
      date.strftime(DATE_FORMAT)
    end
  end
end
