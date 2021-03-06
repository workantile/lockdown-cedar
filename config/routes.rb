Openings::Application.routes.draw do
  devise_for :admins

  get 'access/:address/:rfid' => 'access#show'

  namespace :admin do
    resources :admins
    resources :door_controllers
    resources :all_member_events
    resources :members do
    	get 'billing', :on => :collection
      post 'export', :on => :collection
      patch 'invoiced', :on => :member
      post 'find_key', :on => :collection
      delete 'destroy_delayed_updates', :on => :member
    end

    get "reports" => "reports#index"
    post "reports" => "reports#export"
  end

  root :to => "home#index"

end
