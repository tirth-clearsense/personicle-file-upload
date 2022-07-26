Rails.application.routes.draw do
  resources :user_images, :except => [:destroy]
  # match "/user_images/delete" => "user_images#destrosy", :via => [:delete]
  delete "/user_images/delete" =>  "user_images#destroy"
  # resources :events
  # match 'user_images/:individual_id', to: 'user_images#show', via: [:get, :post], param: 'individual_id'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
