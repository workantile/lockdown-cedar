LockdownRails::Application.routes.draw do
  devise_for :admins

  namespace :admin do
    resources :admins
    resources :members
  end

  root :to => "home#index"
  
end
