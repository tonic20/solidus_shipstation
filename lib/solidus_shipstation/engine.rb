# frozen_string_literal: true

module SolidusShipstation
  class Engine < Rails::Engine
    engine_name 'solidus_shipstation'
    config.autoload_paths += %W[#{config.root}/lib]

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'solidus_shipstation.config' do |app|
      app.config.filter_parameters.push(
        SolidusShipstation.config.username_param,
        SolidusShipstation.config.password_param
      )
    end

    config.to_prepare do
      Dir.glob(File.join(__dir__, '../overrides/**/*.rb')) do |file|
        require_dependency file
      end
    end
  end
end
