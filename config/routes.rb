Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "/auth"    => "auth#index", :as => "auth"
  get "/success" => "home#success", :as => "success"
  # Defines the root path route ("/")
  root "home#index"
end
