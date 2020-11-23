# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'spree/testing_support/extension_rake'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task :default do
  if Dir['spec/dummy'].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir('../../')
  end
  Rake::Task[:spec].invoke
end

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'solidus_shipstation'
  ENV['DB'] = 'postgres'
  Rake::Task['extension:test_app'].invoke
end

desc 'Open an IRB session preloaded with this gem'
task :console do
  ENV['RAILS_ENV'] = 'test'
  require File.expand_path('spec/dummy/config/environment.rb', __dir__)
  ARGV.clear
  Rails::Command.invoke 'console'
end


task release: [:'release:source_control_push']
