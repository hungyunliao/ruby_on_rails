class ArticlesController < BaseController

  ##
  # Fetch all articles.
  def index
    articles = Article.all
    render json: articles
  end

  ##
  # Fetch certain article by id.
  def show
    article = Article.find(params[:id])
    render json: article
  end

  ##
  # Create an article.
  def create
    article = Article.new(article_params)

    if article.save
      render json: article, status: :created
    else
      render json: ActiveModelSerializers::SerializableResource.new(article, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Update an article.
  def update
    article = Article.find(params[:id])

    if article.update(article_params)
      render json: article
    else
      render json: ActiveModelSerializers::SerializableResource.new(article, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Destroy an article.
  def destroy
    article = Article.find(params[:id])

    if article.destroy
      render json: {}, status: :no_content
    else
      render json: ActiveModelSerializers::SerializableResource.new(article, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :status)
  end
end
