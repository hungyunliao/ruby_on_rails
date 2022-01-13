require 'rails_helper'

RSpec.describe 'Comment requests', type: :request do
  let(:comment)                         { create(:comment, article_id: article.id) }
  let(:article)                         { create(:article) }
  let(:invalid_article_id)              { '0' }
  let(:comment_commenter)               { 'comment_commenter' }
  let(:comment_body)                    { 'comment_body' }
  let(:comment_submit_status_approved)  { 'approved' }
  let(:comment_submit_status_submitted) { 'submitted' }
  let(:not_found_error)                 { ['errors.messages.not_found'] }

  # Create
  describe 'POST /articles/:article_id/comments' do
    context 'with a valid article id' do
      before do
        post "/articles/#{article.id}/comments", params: {
                                                   comment: {
                                                     commenter:     comment_commenter,
                                                     body:          comment_body,
                                                     submit_status: comment_submit_status_approved
                                                   }
                                                 }
      end

      it('creates the comment')             { expect(JSON.parse(response.body)['comment']['body']).to eq(comment_body) }
      it('sets submit_status to submitted') { expect(JSON.parse(response.body)['comment']['submit_status']).to eq(comment_submit_status_submitted) }
      it('returns status code 201')         { expect(response).to have_http_status(201) }
    end

    context 'without a valid article id' do
      before { post "/articles/#{invalid_article_id}/comments", params: { comment: { commenter: comment_commenter, body: comment_body } } }

      it('returns errors')          { expect(JSON.parse(response.body)['errors']['id']).to eq(not_found_error) }
      it('returns status code 404') { expect(response).to have_http_status(404) }
    end
  end

  # Read
  describe 'GET /articles/:article_id/comments' do
    context 'with a comment id' do
      before { get "/articles/#{article.id}/comments/#{comment.id}" }

      it('returns the comment')     { expect(JSON.parse(response.body)['comment']['id']).to eq(comment.id) }
      it('returns status code 200') { expect(response).to have_http_status(200) }
    end
  end

  # Update
  describe 'PUT /articles/:article_id/comments' do
    before { put "/articles/#{article.id}/comments/#{comment.id}", params: { comment: { commenter: 'new_commenter' } } }

    it 'updates the comment' do
      comment.reload

      expect(comment.commenter).to eq('new_commenter')
    end

    it('returns status code 200') { expect(response).to have_http_status(200) }
  end

  # Delete
  describe 'DELETE /articles/:article_id/comments' do
    before { delete "/articles/#{article.id}/comments/#{comment.id}" }

    it('returns status code 204') { expect(response).to have_http_status(204) }
  end

end