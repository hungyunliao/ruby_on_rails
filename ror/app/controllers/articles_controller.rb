class ArticlesController < BaseController

  ##
  # Fetch all articles.
  #
  # @return [Array<Article>] a list of Articles.
  def index
    @articles = Article.all
    render json: ActiveModelSerializers::SerializableResource.new(@articles, each_serializer: ArticleSerializer).as_json
  end

  ##
  # Fetch certain article by id.
  #
  # @return [Article] the article object.
  def show
    @article = Article.find(params[:id])
    render json: ActiveModelSerializers::SerializableResource.new(@article, serializer: ArticleSerializer).as_json
  end

  ##
  # Create an article.
  #
  # @return [Article] the article object.
  def create
    @article = Article.new(article_params)

    if @article.save
      render json: ActiveModelSerializers::SerializableResource.new(@article, serializer: ArticleSerializer).as_json, status: :created
    else
      render json: ActiveModelSerializers::SerializableResource.new(@article, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Update an article.
  #
  # @return [Article] the article object being updated.
  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      render json: ActiveModelSerializers::SerializableResource.new(@article, serializer: ArticleSerializer).as_json
    else
      render json: ActiveModelSerializers::SerializableResource.new(@article, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Destroy an article.
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    if @article.destroyed?
      render json: {}, status: :no_content
    else
      render json: ActiveModelSerializers::SerializableResource.new(@article, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :status)
  end
end
