Kite::Application.routes.draw do
  resources :venues do
    member do
      get 'unsubscribe'
    end
  end
  resources :events do
  	member do
  		get 'fav'
  	end
  end
  devise_for :users

  root :to => 'categories#index'
  get 'about' => 'pages#about'
  get 'list' => 'events#list'
end