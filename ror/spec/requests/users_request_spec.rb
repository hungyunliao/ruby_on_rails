require "rails_helper"

RSpec.describe "User", :type => :request do

    describe ".show" do
        it "shows user info" do
            @expected = { "first" => "John", "last" => "Potter", "gender" => "male", "age" => 46 }.to_json

            headers = { "ACCEPT" => "application/json" }
            get "/users/1", :headers => headers

            response.body.should == @expected
        end
    end
end
