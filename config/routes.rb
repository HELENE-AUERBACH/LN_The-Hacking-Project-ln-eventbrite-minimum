Rails.application.routes.draw do
  get 'static_pages/index'
  get 'static_pages/secret'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :events do
    resources :attendances
    resources :charges, only: [:new, :create]
  end
  resources :users, only: [:show]
  root 'static_pages#index'
end
