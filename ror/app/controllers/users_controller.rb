class UsersController < ApplicationController
    def index
        render json: { "abc": "123"}
    end
end