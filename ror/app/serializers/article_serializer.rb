class ArticleSerializer < ApplicationSerializer
  attributes :id, :title, :body, :status, :created_at, :updated_at
end