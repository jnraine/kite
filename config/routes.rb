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
  get 'blog' => 'pages#blog'
  get 'feedback' => 'pages#feedback'
  get 'guidelines' => 'pages#guidelines'
  get 'list' => 'events#list'
end