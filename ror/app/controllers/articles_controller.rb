class ArticlesController < BaseController
  include JsonResponse

  ##
  # Fetch all articles.
  #
  # @return [Array<Article>] a list of Articles.
  def index
    @articles = Article.all
    render json: json_response(RESPONSE_STATUS[:success], @articles)
  end

  ##
  # Fetch certain article by id.
  #
  # @return [Article] the article object.
  def show
    @article = Article.find(params[:id])
    render json: json_response(RESPONSE_STATUS[:success], @article)
  end

  ##
  # Create an article.
  #
  # @return [Article] the article object.
  def create
    @article = Article.new(article_params)

    if @article.save
      render json: json_response(RESPONSE_STATUS[:success], @article), status: :created
    else
      render json: json_response(RESPONSE_STATUS[:error], @article.errors), status: :unprocessable_entity
    end
  end

  ##
  # Update an article.
  #
  # @return [Article] the article object being updated.
  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      render json: json_response(RESPONSE_STATUS[:success], @article)
    else
      render json: json_response(RESPONSE_STATUS[:error], @article.errors), status: :unprocessable_entity
    end
  end

  ##
  # Destroy an article.
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    if @article.destroyed?
      render json: json_response(RESPONSE_STATUS[:success]), status: :no_content
    else
      render json: json_response(RESPONSE_STATUS[:error], @article.errors), status: :unprocessable_entity
    end
  end

  private
  def article_params
    params.require(:article).permit(:title, :body, :status)
  end
end
