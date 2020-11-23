# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  get  '/shipstation' => 'shipstation#export'
  post '/shipstation' => 'shipstation#shipnotify'
end
