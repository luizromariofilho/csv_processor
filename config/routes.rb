# frozen_string_literal: true

Rails.application.routes.draw do
  defaults format: :json do
    resources :users

    namespace :csv_exports do
      resources :users, only: :index
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
