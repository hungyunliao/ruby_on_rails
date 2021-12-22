require "rails_helper"

RSpec.describe "My first request test", :type => :request do
    it "creates user" do
        headers = { "ACCEPT" => "application/json" }
        get "/users", :headers => headers

        printf response
    end
end
