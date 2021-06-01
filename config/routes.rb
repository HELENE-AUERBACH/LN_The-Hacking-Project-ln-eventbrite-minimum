Rails.application.routes.draw do
  devise_for :users
  get 'static_pages/index'
  get 'static_pages/secret'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :events do
    resources :attendances
    resources :charges, only: [:new, :create]
    scope '/checkout' do
      post 'create', to: 'checkout#create', as: 'checkout_create'
      get 'cancel', to: 'checkout#cancel', as: 'checkout_cancel'
      get 'success', to: 'checkout#success', as: 'checkout_success'
    end
  end
  resources :users, only: [:show]
  namespace :static do
    resources :team, :contact, :ui_kit, only: [:index]
  end
  root 'static_pages#index'
end
