class ArticlesController < ApplicationController

  def index
    @articles = Article.all
    render json: @articles
  end

  def show
    @article = Article.find(params[:id])
    render json: @article
  end

  def new
    @article = Article.new
    render json: @article
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      render json: @article
    else
      render json: { "error" => @article.errors }
    end
  end

  def edit
    @article = Article.find(params[:id])
    render json: @article
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      render json: @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path
  end

  private
    def article_params
      params.permit(:title, :body, :status)
    end
end
