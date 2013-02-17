Openings::Application.routes.draw do
  devise_for :admins

  get 'access/:address/:rfid' => 'access#show'

  namespace :admin do
    resources :admins
    resources :door_controllers
    resources :members do
    	get 'billing', :on => :collection
      post 'export', :on => :collection
      put 'invoiced', :on => :member
      delete 'destroy_delayed_updates', :on => :member
    end

    get "reports" => "reports#index"
    post "reports" => "reports#export"
  end

  root :to => "home#index"
  
end
