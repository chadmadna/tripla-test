# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
    skip: :sessions,
    path: '',
    path_names: { sign_in: 'login', sign_out: 'logout' },
    defaults: { format: :json }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
# config/routes.rb

  namespace :api do
    get 'users', to: 'users#index'
    get 'following', to: 'users#following'
    get 'followers', to: 'users#followers'
    get 'users/:username', to: 'users#show'
    post 'users/:username/follow', to: 'users#follow'
    delete 'users/:username/unfollow', to: 'users#unfollow'
    get 'sleep_schedules', to: 'schedules#index'
    post 'clock_in', to: 'schedules#clock_in'
    post 'clock_out', to: 'schedules#clock_out'
  end
end
