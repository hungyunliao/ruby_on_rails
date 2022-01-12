class CommentSerializer < ApplicationSerializer
  attributes :id, :commenter, :body, :submit_status, :created_at, :updated_at
end