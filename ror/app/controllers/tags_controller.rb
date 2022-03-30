class TagsController < BaseController

  ##
  # Fetch all tags. An optional url params 'filter' can be included in the request. If a filter is included, the action will return all tags containing the
  # keyword specified by the params 'filter', otherwise, it will return all tags.
  def index
    filter = params['filter']
    tags   = filter ? Tag.with_name_like(filter) : Tag.all
    render json: tags
  end

  ##
  # Fetch certain tag by id.
  def show
    tag = Tag.find(params[:id])
    render json: tag
  end

  ##
  # Create a Tag.
  def create
    tag = Tag.new(tag_params)

    if tag.save
      render json: tag, status: :created
    else
      render json: ActiveModelSerializers::SerializableResource.new(tag, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Update a tag.
  def update
    tag = Tag.find(params[:id])

    if tag.update(tag_params)
      render json: tag
    else
      render json: ActiveModelSerializers::SerializableResource.new(tag, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Destroy a tag. A tag is not destroyable if there is any article associated with it. This logic is handled at the Model layer (Tag).
  def destroy
    tag = Tag.find(params[:id])

    if tag.destroy
      render json: {}, status: :no_content
    else
      render json: ActiveModelSerializers::SerializableResource.new(tag, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Nested endpoints
  #

  ##
  # Fetch tags for a certain article.
  def article_tags
    article = Article.find(params[:article_id])
    render json: article.tags
  end

  ##
  # Attach a tag to a certain article.
  def attach_tag
    tagging = Tagging.new(article_id: params[:article_id], tag_id: params[:tag_id])

    if tagging.save
      article = Article.find(params[:article_id])
      render json: article.tags
    else
      render json: ActiveModelSerializers::SerializableResource.new(tagging, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Detach a tag from a certain article.
  def detach_tag
    tagging = Tagging.find_by(article_id: params[:article_id], tag_id: params[:id])

    unless tagging
      return not_found_error
    end

    if tagging.destroy
      article = Article.find(params[:article_id])
      render json: article.tags
    else
      render json: ActiveModelSerializers::SerializableResource.new(tagging, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Retrieve articles associated with a tag.
  def retreive_articles
    tag      = Tag.find(params[:tag_id])
    articles = tag.articles
    render json:
    articles
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
