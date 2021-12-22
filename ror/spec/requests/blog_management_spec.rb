require "rails_helper"

RSpec.describe "Blog Management", type: :request do
    describe "GET /articles" do
        it "gets a Blog" do
            get "/articles/new"
    
            expect(response.content_type).to eq("text/html; charset=UTF-8")
        end
    end
end
