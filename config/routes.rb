Openings::Application.routes.draw do
  devise_for :admins

  get 'access/:address/:rfid' => 'access#show'

  namespace :admin do
    resources :admins
    resources :members do
    	get 'billing', :on => :collection
      put 'invoiced', :on => :member
    end

    get "reports" => "reports#index"
  end

  root :to => "home#index"
  
end
