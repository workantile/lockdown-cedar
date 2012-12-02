LockdownRails::Application.routes.draw do
  devise_for :admins

  namespace :admin do
    resources :admins
  end

  root :to => "home#index"
  
end
