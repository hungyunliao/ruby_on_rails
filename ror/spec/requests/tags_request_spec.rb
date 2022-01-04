require 'rails_helper'

RSpec.describe "Tags", type: :request do
    describe "POST /tags" do
        post "/tags"
        it "creates a new tag with the name given" do
        end
    end

    describe "GET /tags" do
    end

    describe "DELETE /tags" do
    end
end
