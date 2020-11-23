# frozen_string_literal: true

module SolidusShipstation
  class Configuration < ::Spree::Preferences::Configuration
    DEFAULT_CARRIES = {
      UPS: {
        name: 'UPS',
        tracking_url: 'https://www.ups.com/track?loc=en_US&tracknum=:tracking'
      },
      UPSMI: {
        name: 'UPS Mail Innovations',
        tracking_url: 'https://www.ups.com/track?loc=en_US&tracknum=:tracking'
      },
      FedEx: {
        name: 'FedEx',
        tracking_url: 'https://www.fedex.com/apps/fedextrack/index.html?tracknumbers=:tracking&cntry_code=us'
      },
      USPS: {
        name: 'USPS',
        tracking_url: 'https://tools.usps.com/go/TrackConfirmAction?tRef=fullpage&tLc=3&text28777=&tLabels=:tracking'
      }
    }.freeze

    preference :username,                :string
    preference :username_param,          :string,  default: 'SS-UserName'
    preference :password,                :string
    preference :password_param,          :string,  default: 'SS-Password'
    preference :weight_units,            :string
    preference :ssl_encrypted,           :boolean, default: true
    preference :capture_at_notification, :boolean, default: false
    preference :carriers,                :hash,    default: DEFAULT_CARRIES.dup.with_indifferent_access
    preference :default_carrier,         :symbol,  default: :USPS
    preference :error_tracker,           :proc,    default: -> { proc {} }

    def register_carrier(id, name, tracking_url)
      unless tracking_url.include?(':tracking')
        raise ArgumentError, 'invalid `tracking_url`. It have to include `:tracking` replacable part'
      end

      carriers[id] = { name: name, tracking_url: tracking_url }
    end
  end
end
