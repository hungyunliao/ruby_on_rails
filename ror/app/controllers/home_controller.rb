class HomeController < ApplicationController
  def index
    render json: { :sucess => true, :message => "Hello World." }
  end
end
