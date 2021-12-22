class UsersController < ApplicationController
    def index
        render json: { :first => "John", :last => "Potter", :gender => "male", :age => 46 }
    end
end