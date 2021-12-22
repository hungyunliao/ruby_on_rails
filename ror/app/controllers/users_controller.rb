class UsersController < ApplicationController
    def index
    end

    def show
        render json: { :first => "John", :last => "Potter", :gender => "male", :age => 46 }
    end
end