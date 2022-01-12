class TagsController < BaseController

  ##
  # Fetch all tags. An optional url params 'filter' can be included in the request. If a filter is included, the action
  # will return all tags containing the keyword specified by the params 'filter', otherwise, it will return all tags.
  #
  # @return [Array<Tag>] a list of Tags.
  def index
    @filter = params['filter']
    @tags   = @filter ? Tag.where('name LIKE ?', "%#{@filter}%") : Tag.all
    render json: ActiveModelSerializers::SerializableResource.new(@tags, each_serializer: TagSerializer).as_json
  end

  ##
  # Fetch certain tag by id.
  #
  # @return [Tag] the tag object.
  def show
    @tag = Tag.find(params[:id])
    render json: ActiveModelSerializers::SerializableResource.new(@tag, serializer: TagSerializer).as_json
  end

  ##
  # Create a Tag.
  #
  # @return [Tag] the tag object.
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: ActiveModelSerializers::SerializableResource.new(@tag, serializer: TagSerializer).as_json, status: :created
    else
      render json: ActiveModelSerializers::SerializableResource.new(@tag, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Update a tag.
  #
  # @return [Tag] the tag object being updated.
  def update
    @tag = Tag.find(params[:id])

    if @tag.update(tag_params)
      render json: ActiveModelSerializers::SerializableResource.new(@tag, serializer: TagSerializer).as_json
    else
      render json: ActiveModelSerializers::SerializableResource.new(@tag, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Destroy a tag. A tag is not destroyable if there is any article associated with it. This logic is handled at the
  # Model layer (Tag).
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    if @tag.destroyed?
      render json: {}, status: :no_content
    else
      render json: ActiveModelSerializers::SerializableResource.new(@tag, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Nested endpoints
  #

  ##
  # Fetch tags for a certain article.
  #
  # @return [Array<Tag>] a list of Tags.
  def article_tags
    @article = Article.find(params[:article_id])
    render json: ActiveModelSerializers::SerializableResource.new(@article.tags, each_serializer: TagSerializer).as_json
  end

  ##
  # Attach a tag to a certain article.
  #
  # @return [Array<Tag>] a list of Tags associated with the article.
  def attach_tag
    @tagging = Tagging.new(article_id: params[:article_id], tag_id: params[:tag_id])

    if @tagging.save
      @article = Article.find(params[:article_id])
      render json: ActiveModelSerializers::SerializableResource.new(@article.tags, each_serializer: TagSerializer).as_json
    else
      render json: ActiveModelSerializers::SerializableResource.new(@tagging, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Detach a tag from a certain article.
  #
  # @return [Array<Tag>] a list of Tags associated with the article.
  def detach_tag
    @tagging = Tagging.find_by(article_id: params[:article_id], tag_id: params[:id])

    unless @tagging
      return not_found_error
    end

    @tagging.destroy

    if @tagging.destroyed?
      @article = Article.find(params[:article_id])
      render json: ActiveModelSerializers::SerializableResource.new(@article.tags, each_serializer: TagSerializer).as_json
    else
      render json: ActiveModelSerializers::SerializableResource.new(@tagging, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Retrieve articles associated with a tag.
  #
  # @return [Array<Article>] a list of Articles associated with the tag.
  def retreive_articles
    @tag      = Tag.find(params[:tag_id])
    @articles = @tag.articles
    render json: ActiveModelSerializers::SerializableResource.new(@tarticles, serializer: ArticleSerializer).as_json
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
