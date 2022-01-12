Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "home#index"

  resources :articles do
    resources :comments
    get "/tags", to: "tags#article_tags"
    post "/tags", to: "tags#attach_tag"
    delete "/tags/:id", to: "tags#detach_tag"
  end

  resources :tags do
    get "/articles", to: "tags#retreive_articles"
  end
end
