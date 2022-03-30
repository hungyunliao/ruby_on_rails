require 'rails_helper'

RSpec.describe 'Article requests', type: :request do
  let(:expected_error_taken)   { ['has already been taken'] }
  let(:existing_article_title) { 'existing_article_title' }
  let(:another_article_title)  { 'another_article_title' }
  let(:article_body)           { 'article_body' }
  let(:article_status)         { 'public' }

  before { post '/articles', params: { article: { title: existing_article_title, body: article_body, status: article_status } } }

  let(:article) { Article.find_by(title: existing_article_title) }

  # Create
  describe 'POST /articles' do
    context 'with a title that already exists' do
      before { post '/articles', params: { article: { title: existing_article_title, body: article_body, status: article_status } } }

      it('returns errors')          { expect(JSON.parse(response.body)['errors']).to eq( { "title" => expected_error_taken } ) }
      it('returns status code 422') { expect(response).to have_http_status(422) }
    end

    context 'with a title that does not exist' do
      before { post '/articles', params: { article: { title: another_article_title, body: article_body, status: article_status } } }

      it('creates the article')     { expect(JSON.parse(response.body)['article']['title']).to eq(another_article_title) }
      it('returns status code 201') { expect(response).to have_http_status(201) }
    end
  end

  # Read
  describe 'GET /articles' do
    context 'without /:article_id specified' do
      before { get '/articles' }

      it('returns articles containing the article') { expect(JSON.parse(response.body)['articles']).to include(article.as_json) }
      it('returns status code 200')                 { expect(response).to have_http_status(200) }
    end

    context 'with /:article_id specified' do
      before { get "/articles/#{article.id}" }

      it('returns the article')     { expect(JSON.parse(response.body)['article']).to eq(article.as_json) }
      it('returns status code 200') { expect(response).to have_http_status(200) }
    end
  end

  # Update
  describe 'PUT /articles' do
    before { post '/articles', params: { article: { title: another_article_title, body: article_body, status: article_status } } }

    context 'with a new title that does not exist' do
      before { put "/articles/#{article.id}", params: { article: { title: 'yet_another_article_title' } } }

      it 'updates the article' do
        article.reload

        expect(JSON.parse(response.body)['article']).to include(article.as_json)
      end

      it('returns status code 200') { expect(response).to have_http_status(200) }
    end

    context 'with a new title that exists' do
      before { put "/articles/#{article.id}", params: { article: { title: another_article_title } } }

      it('returns errors')          { expect(JSON.parse(response.body)['errors']).to eq( { 'title' => expected_error_taken } ) }
      it('returns status code 422') { expect(response).to have_http_status(422) }
    end
  end

  # Delete
  describe 'DELETE /articles' do
    before { delete "/articles/#{article.id}" }

    it('returns status code 204') { expect(response).to have_http_status(204) }
    it('deletes the article')     { expect(Article.find_by(id: article.id)).to be_nil }
  end
end