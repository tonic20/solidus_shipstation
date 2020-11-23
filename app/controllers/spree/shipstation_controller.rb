# frozen_string_literal: true

module Spree
  class ShipstationController < Spree::BaseController
    protect_from_forgery with: :null_session, only: [:shipnotify]
    force_ssl if: :with_ssl?
    before_action :authenticate!

    layout nil

    def export
      @shipments = ShipstationQuery.export(date_param(:start_date), date_param(:end_date), params[:page])

      respond_to do |format|
        format.xml
      end
    end

    def shipnotify
      if SolidusShipstation::Notice.call(notice_config)
        head :ok
      else
        head :bad_request
      end
    end

    private

    def date_param(name)
      return if params[name].nil?

      Time.strptime("#{params[name]} UTC", '%m/%d/%Y %H:%M %Z')
    end

    def with_ssl?
      SolidusShipstation.config.ssl_encrypted
    end

    def authenticate!
      head 401 unless SolidusShipstation.valid_credentials?(params)
    end

    def notice_config
      params.except('action', 'format', 'controller',
        SolidusShipstation.config.username_param, SolidusShipstation.config.password_param)
    end
  end
end
