require "rails_helper"

RSpec.describe "User requests", :type => :request do
  describe "GET /users" do

    context "with a valid user id" do
      let(:expected) {
        { :first => "John", :last => "Potter", :gender => "male", :age => 46 }.to_json()
      }
      before { get "/users/1" }

      it "has 200 code when valid id presents" do
        expect(response).to have_http_status(200)
      end

      it "has the correct expected JSON data" do
        response.body.should == expected
      end

    end

    context "without a valid user id" do
      before { get "/users/" }

      it "has 404 code when no valid id presents" do
        expect(response).to have_http_status(404)
      end
    end
  
  end
end
