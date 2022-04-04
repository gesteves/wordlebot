Rails.application.routes.draw do
  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "/auth"    => "auth#index", :as => "auth"
  get "/success" => "home#success", :as => "success"

  post 'slack/events' => "events#index", :as => "events"
  # Defines the root path route ("/")
  root "home#index"
end
