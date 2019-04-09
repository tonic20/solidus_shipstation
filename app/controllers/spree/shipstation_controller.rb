module Spree

  class ShipstationController < Spree::BaseController

    include Spree::BasicSslAuthentication
    include Spree::DateParamHelper

    protect_from_forgery with: :null_session, only: [:shipnotify]

    def export
      @shipments = Spree::Shipment.exportable
                                  .between(date_param(:start_date),
                                           date_param(:end_date))
                                  .page(params[:page])
                                  .per(50)

      respond_to do |format|
        format.xml { render 'spree/shipstation/export', layout: false }
      end
    end

    # TODO: log when request are succeeding and failing
    def shipnotify
      ShipmentLog.log(request)

      notice = Spree::ShipmentNotice.new(params)

      if notice.apply
        head :ok
      else
        head :bad_request
      end
    end

  end

end
