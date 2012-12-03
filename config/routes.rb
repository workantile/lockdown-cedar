LockdownRails::Application.routes.draw do
  devise_for :admins

  get 'access/:address/:rfid' => 'access#show'

  namespace :admin do
    resources :admins
    resources :members
  end

  root :to => "home#index"
  
end
