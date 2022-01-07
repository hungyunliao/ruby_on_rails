require 'rails_helper'

RSpec.describe 'Tag requests', type: :request do
  let(:existed_tag_name)   { 'existedTagName' }
  let(:invalid_tag_id)     { '0' }
  let(:invalid_article_id) { '0' }

  @existed_tags_length = nil
  @existed_tag_object  = nil
  @existed_tag_id      = nil

  before do
    post '/tags', params: { :name => existed_tag_name }

    @existed_tag_object = JSON.parse(response.body)['message']
    @existed_tag_id     = @existed_tag_object['id']

    get '/tags'

    @existed_tags_length = JSON.parse(response.body)['message'].size
  end

  describe 'POST /tags' do
    context 'with a tag name not yet exist' do
      let(:new_tag_name) { 'newTagName' }

      before { post '/tags', params: { :name => new_tag_name } }

      it('creates a new tag with the tag name') { expect(JSON.parse(response.body)['message']['name']).to eq(new_tag_name) }
    end

    context 'with a tag name already existed' do
      let(:expected) { { 'name' => ['has already been taken'] } }

      before { post '/tags', params: { :name => existed_tag_name } }

      it('returns an error message') { expect(JSON.parse(response.body)['message']).to include(expected) }
    end
  end

  describe 'PUT /tags' do
    let(:updated_tag_name) { 'updatedTagName' }

    context 'with a valid tag id' do
      before { put "/tags/#{@existed_tag_id}", params: { :name => updated_tag_name } }

      it('updates the name of the tag') { expect(JSON.parse(response.body)['message']['name']).to eq(updated_tag_name) }
    end

    context 'with an invalid tag id' do
      let(:expected) { 'Tag not found.' }

      before { put "/tags/#{invalid_tag_id}", params: { :name => updated_tag_name } }

      it('returns an error message') { expect(JSON.parse(response.body)['message']).to eq(expected) }
    end
  end

  describe 'GET /tags' do
    context 'with the filter query param' do
      let(:wrong_filter_query) { 'fooBar' }
      let(:right_filter_query) { 'existed' }

      context 'with a filter that matches the tag name' do
        before { get "/tags?filter=#{right_filter_query}" }

        it('returns tags containing the tag') { expect(JSON.parse(response.body)['message']).to include(@existed_tag_object) }
      end

      context 'with a filter that does not match any tag names' do
        before { get "/tags?filter=#{wrong_filter_query}" }

        it('returns tags not containing the tag') { expect(JSON.parse(response.body)['message']).not_to include(@existed_tag_object) }
      end
    end

    context 'without the filter query param' do
      before { get '/tags' }

      it('has the length equals to the target length') { expect(JSON.parse(response.body)['message'].size).to eq(@existed_tags_length) }
      it('returns tags containing the tag')            { expect(JSON.parse(response.body)['message']).to include(@existed_tag_object) }
    end
  end

  #
  # Nested resources
  #
  let(:existed_article_title)  { 'existedArticleTitle' }
  let(:existed_article_body)   { 'existedArticleBody' }
  let(:existed_article_status) { 'public' }

  @existed_article_object = nil
  @existed_article_id     = nil

  before do
    post '/articles', params: {
      :title  => existed_article_title,
      :body   => existed_article_body,
      :status => existed_article_status
    }

    @existed_article_object = JSON.parse(response.body)
    @existed_article_id     = @existed_article_object['id']
  end

  describe 'POST /articles/:article_id/tags' do
    context 'with a valid article id' do
      @returned_tag = nil

      before do
        post "/articles/#{@existed_article_id}/tags", params: { :tag_id => @existed_tag_id }
        @returned_tag = JSON.parse(response.body)['message'][0]
      end

      it('attaches the tag to the article')              { expect(@returned_tag).to include({'name' => existed_tag_name}) }
      it('increases the tagging count by 1 for the tag') { expect(@returned_tag['taggings_count']).to eq(1) }
    end
  end

  describe 'DELETE /articles/:article_id/tags/:tag_id' do
    before { post "/articles/#{@existed_article_id}/tags", params: { :tag_id => @existed_tag_id } }

    context 'with a valid tag id' do
      @returned_tag = nil

      before do
        delete "/articles/#{@existed_article_id}/tags/#{@existed_tag_id}"
        @returned_tag = JSON.parse(response.body)['message']
      end

      it('detaches the tag from the article') { expect(@target_tag).to eq(nil) }

      it 'decreases the taggings count by 1 for the tag' do
        @tag = Tag.find_by(id: @existed_tag_id)
        expect(@tag.taggings_count).to eq(0)
      end
    end
  end

  describe 'DELETE /tags/:tag_id' do
    context 'without any article associated' do
      before { delete "/tags/#{@existed_tag_id}" }

      it 'deletes the tag' do
        get '/tags'
        expect(JSON.parse(response.body)['message']).not_to include(@existed_tag_object)
      end

      it 'detaches the tag from the article' do
        get "/articles/#{@existed_article_id}/tags"
        expect(JSON.parse(response.body)['message']).not_to include(@existed_tag_object)
      end
    end

    context 'with at least one article associated' do
      before do
        post "/articles/#{@existed_article_id}/tags", params: { :tag_id => @existed_tag_id }
        delete "/tags/#{@existed_tag_id}"
      end

      it 'returns an error' do
        @expected = 'Cannot delete the tag.'
        expect(JSON.parse(response.body)['message']).to eq(@expected)
      end

      it 'does not detach the tag from the article' do
        get "/articles/#{@existed_article_id}/tags"
        expect(JSON.parse(response.body)['message'][0]).to include({'name' => existed_tag_name})
      end
    end
  end
end
