require "rails_helper"

RSpec.describe "My first request test", :type => :request do

    it "creates user" do
        @expected = { "first" => "John", "last" => "Potter", "gender" => "male", "age" => 46 }.to_json

        headers = { "ACCEPT" => "application/json" }
        get "/users", :headers => headers

        response.body.should == @expected
    end
end
