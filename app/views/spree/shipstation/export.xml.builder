# frozen_string_literal: true

xml = Builder::XmlMarkup.new
xml.instruct!
xml.Orders(pages: @shipments.total_pages) do
  @shipments.each do |shipment|
    order = shipment.order

    xml.Order do
      xml.OrderID        shipment.id
      xml.OrderNumber    shipment.number # do not use shipment.order.number as this presents lookup issues
      xml.OrderDate      SolidusShipstation::ExportHelper.to_date_str(order.completed_at)
      xml.OrderStatus    shipment.state
      xml.LastModified   SolidusShipstation::ExportHelper.to_date_str([order.completed_at, shipment.updated_at].max)
      xml.ShippingMethod shipment.shipping_method&.name
      xml.OrderTotal     order.total
      xml.TaxAmount      order.tax_total
      xml.ShippingAmount order.ship_total
      xml.CustomField1   order.number

      xml.Customer do
        xml.CustomerCode order.email.slice(0, 50)
        SolidusShipstation::ExportHelper.address(xml, order, :bill)
        SolidusShipstation::ExportHelper.address(xml, order, :ship)
      end

      xml.Items do
        shipment.manifest.each do |manifest|
          line = manifest.line_item
          variant = manifest.variant
          quantity = manifest.quantity - manifest.states.fetch('canceled', 0)
          next unless quantity.positive?

          xml.Item do
            xml.SKU         variant.sku
            xml.Name        [variant.product.name, variant.options_text].join(' ')
            xml.ImageUrl    SolidusShipstation::ExportHelper.product_image_with_fallback(variant)
            xml.Weight      variant.weight.to_f
            xml.WeightUnits SolidusShipstation.config.weight_units
            xml.Quantity    quantity
            xml.UnitPrice   line.price

            if variant.option_values.present?
              xml.Options do
                variant.option_values.each do |value|
                  xml.Option do
                    xml.Name  value.option_type.presentation
                    xml.Value value.presentation
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
