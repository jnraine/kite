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
  devise_for :users, :controllers => { :sessions => 'sessions' }
  devise_for :hosts#, :skip => :sessions

  root :to => 'categories#index'
  get 'about' => 'pages#about'
  get 'blog' => 'pages#blog'
  get 'feedback' => 'pages#feedback'
  get 'guidelines' => 'pages#guidelines'
  get 'help' => 'pages#help'
  get 'list' => 'events#list'
end