module Spree

  module BasicSslAuthentication

    extend ActiveSupport::Concern

    included do
      force_ssl if: :ssl_configured?
      before_action :authenticate
    end

    protected

    def authenticate
      if Spree::Config.shipstation_basic_auth_enabled
        authenticate_or_request_with_http_basic do |username, password|
          username == Spree::Config.shipstation_username && password == Spree::Config.shipstation_password
        end
      end
    end

    private

    def ssl_configured?
      Spree::Config.shipstation_ssl_encrypted
    end

  end

end
