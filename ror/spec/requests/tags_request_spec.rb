require 'rails_helper'

RSpec.describe "Tag requests", type: :request do
    let(:existed_tag_name) { "existedTagName" }
    let(:invalid_tag_id) { "0" }
    let(:invalid_article_id) { "0" }
    @existed_tags_length = nil
    @existed_tag_object = nil
    @existed_tag_id = nil
    before do
        post "/tags", params: { :name => existed_tag_name }
        @existed_tag_object = JSON.parse(response.body)["message"]
        @existed_tag_id = @existed_tag_object["id"]

        get "/tags"
        @existed_tags_length = JSON.parse(response.body)["message"].size
    end

    describe "POST /tags" do
        context "with a tag name not yet exist" do
            let(:new_tag_name) { "newTagName" }
            before do
                post "/tags", params: { :name => new_tag_name }
            end

            it "creates a new tag with the tag name" do
                expect(JSON.parse(response.body)["message"]["name"]).to eq(new_tag_name)
            end
        end

        context "with a tag name already existed" do
            let(:expected) {
                { "name" => ["has already been taken"] }
            }
            before do
                post "/tags", params: { :name => existed_tag_name }
            end

            it "returns an error message" do
                expect(JSON.parse(response.body)["message"]).to include(expected)
            end
        end
    end

    describe "PUT /tags" do
        let(:updated_tag_name) { "updatedTagName" }

        context "with a valid tag id" do
            before do
                put "/tags/#{@existed_tag_id}", params: { :name => updated_tag_name }
            end

            it "updates the name of the tag" do
                expect(JSON.parse(response.body)["message"]["name"]).to eq(updated_tag_name)
            end
        end

        context "with an invalid tag id" do
            let(:expected) { "Tag not found." }
            before do
                put "/tags/#{invalid_tag_id}", params: { :name => updated_tag_name }
            end

            it "returns an error message" do
                expect(JSON.parse(response.body)["message"]).to eq(expected)
            end
        end
    end

    describe "GET /tags" do
        context "with the filter query param" do
            let(:wrong_filter_query) { "fooBar" }
            let(:right_filter_query) { "existed" }
            
            context "with a filter that matches the tag name" do
                before do
                    get "/tags?filter=#{right_filter_query}"
                end
                
                it "returns tags containing the tag" do
                    expect(JSON.parse(response.body)["message"]).to include(@existed_tag_object)
                end
            end

            context "with a filter that does not match any tag names" do
                before do
                    get "/tags?filter=#{wrong_filter_query}"
                end
                
                it "returns tags not containing the tag" do
                    expect(JSON.parse(response.body)["message"]).not_to include(@existed_tag_object)
                end
            end
        end

        context "without the filter query param" do
            before do
                get "/tags"
            end

            it "has the length equals to the target length" do
                expect(JSON.parse(response.body)["message"].size).to eq(@existed_tags_length)
            end

            it "returns tags containing the tag" do
                expect(JSON.parse(response.body)["message"]).to include(@existed_tag_object)
            end
        end
    end

    #
    # Nested resources
    #
    let(:existed_article_title) { "existedArticleTitle" }
    let(:existed_article_body) { "existedArticleBody" }
    let(:existed_article_status) { "public" }
    @existed_article_object = nil
    @existed_article_id = nil
    before do
        post "/articles", params: {
            :title => existed_article_title,
            :body => existed_article_body,
            :status => existed_article_status
        }
        @existed_article_object = JSON.parse(response.body)
        @existed_article_id = @existed_article_object["id"]
    end

    describe "POST /articles/:article_id/tags" do
        context "with a valid article id" do
            @returned_tag = nil
            before do
                post "/articles/#{@existed_article_id}/tags", params: { :tag_id => @existed_tag_id }
                @returned_tag = JSON.parse(response.body)["message"][0]
            end

            it "attaches the tag to the article" do
                expect(@returned_tag).to include({"name" => existed_tag_name})
            end

            it "increases the tagging count by 1 for the tag" do
                expect(@returned_tag["taggings_count"]).to eq(1)
            end
        end
    end

    describe "DELETE /articles/:article_id/tags/:tag_id" do
        before do
            # Attach a tag first for testing
            post "/articles/#{@existed_article_id}/tags", params: { :tag_id => @existed_tag_id }
        end

        context "with a valid tag id" do
            @returned_tag = nil
            before do
                delete "/articles/#{@existed_article_id}/tags/#{@existed_tag_id}"
                @returned_tag = JSON.parse(response.body)["message"]
            end

            it "detaches the tag from the article" do
                expect(@target_tag).to eq(nil)
            end
            
            it "decreases the taggings count by 1 for the tag" do
                @tag = Tag.find_by(id: @existed_tag_id)
                expect(@tag.taggings_count).to eq(0)
            end
        end
    end

    describe "DELETE /tags/:tag_id" do
        context "without any article associated" do
            before do
                delete "/tags/#{@existed_tag_id}"
            end

            it "deletes the tag" do
                get "/tags"
                expect(JSON.parse(response.body)["message"]).not_to include(@existed_tag_object)
            end

            it "detaches the tag from the article" do
                get "/articles/#{@existed_article_id}/tags"
                expect(JSON.parse(response.body)["message"]).not_to include(@existed_tag_object)
            end
        end

        context "with at least one article associated" do
            before do
                post "/articles/#{@existed_article_id}/tags", params: { :tag_id => @existed_tag_id }
                delete "/tags/#{@existed_tag_id}"
            end

            it "returns an error" do
                @expected = "Cannot delete the tag."
                expect(JSON.parse(response.body)["message"]).to eq(@expected)
            end
            
            it "does not detach the tag from the article" do
                get "/articles/#{@existed_article_id}/tags"
                expect(JSON.parse(response.body)["message"][0]).to include({"name" => existed_tag_name})
            end
        end
    end
end
