Kite::Application.routes.draw do
  resources :events

  devise_for :users

  root :to => 'pages#home'
  get 'about' => 'pages#about'
  get 'events' => 'events#index'
  get 'list' => 'events#list'
end
