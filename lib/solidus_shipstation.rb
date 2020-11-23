# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'
require_relative 'solidus_shipstation/configuration'
require_relative 'solidus_shipstation/engine'
require_relative 'solidus_shipstation/export_helper'
require_relative 'solidus_shipstation/notice'
require_relative 'spree/shipstation_query'

module SolidusShipstation
  instance_variable_set(:@config, Configuration.new)
  def self.config
    @config
  end

  def self.setup
    yield config
  end

  def self.track_error(message, e = nil)
    Rails.logger.error(message)
    config.error_tracker.call(e) if e
  end
end
