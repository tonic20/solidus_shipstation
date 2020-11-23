# frozen_string_literal: true

module SolidusShipstation
  class Engine < Rails::Engine
    engine_name 'solidus_shipstation'
    config.autoload_paths += %W[#{config.root}/lib]

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.to_prepare do
      Dir.glob(File.join(__dir__, '../overrides/**/*.rb')) do |file|
        require_dependency file
      end
    end
  end
end
