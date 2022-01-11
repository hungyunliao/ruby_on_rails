class TagsController < BaseController
  include JsonResponse

  ##
  # Fetch all tags. An optional url params 'filter' can be included in the request. If a filter is included, the action
  # will return all tags containing the keyword specified by the params 'filter', otherwise, it will return all tags.
  #
  # @return [Array<Tag>] a list of Tags.
  def index
    @filter = params['filter']
    @tags   = @filter ? Tag.where('name LIKE ?', "%#{@filter}%") : Tag.all
    render json: json_response(RESPONSE_STATUS[:success], @tags)
  end

  ##
  # Fetch certain tag by id.
  #
  # @return [Tag] the tag object.
  def show
    @tag = Tag.find(params[:id])
    render json: json_response(RESPONSE_STATUS[:success], @tag)
  end

  ##
  # Create a Tag.
  #
  # @return [Tag] the tag object.
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: json_response(RESPONSE_STATUS[:success], @tag), status: :created
    else
      render json: json_response(RESPONSE_STATUS[:error], @tag.errors), status: :unprocessable_entity
    end
  end

  ##
  # Update a tag.
  #
  # @return [Tag] the tag object being updated.
  def update
    @tag = Tag.find(params[:id])

    if @tag.update(tag_params)
      render json: json_response(RESPONSE_STATUS[:success], @tag)
    else
      render json: json_response(RESPONSE_STATUS[:error], @tag.errors), status: :unprocessable_entity
    end
  end

  ##
  # Destroy a tag. A tag is not destroyable if there is any article associated with it. This logic is handled at the
  # Model layer (Tag).
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    if @tag.destroyed?
      render json: json_response(RESPONSE_STATUS[:success]), status: :no_content
    else
      render json: json_response(RESPONSE_STATUS[:error], @tag.errors), status: :unprocessable_entity
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
    render json: json_response(RESPONSE_STATUS[:success], @article.tags)
  end

  ##
  # Attach a tag to a certain article.
  #
  # @return [Array<Tag>] a list of Tags associated with the article.
  def attach_tag
    @tagging = Tagging.new(article_id: params[:article_id], tag_id: params[:tag_id])

    if @tagging.save
      @article = Article.find(params[:article_id])
      render json: json_response(RESPONSE_STATUS[:success], @article.tags)
    else
      render json: json_response(RESPONSE_STATUS[:error], @tagging.errors), status: :unprocessable_entity
    end
  end

  ##
  # Detach a tag from a certain article.
  #
  # @return [Array<Tag>] a list of Tags associated with the article.
  def detach_tag
    @tagging = Tagging.find_by(article_id: params[:article_id], tag_id: params[:id])

    unless @tagging
      return render json: json_response(RESPONSE_STATUS[:error]), status: :not_found
    end

    @tagging.destroy

    if @tagging.destroyed?
      @article = Article.find(params[:article_id])
      render json: json_response(RESPONSE_STATUS[:success], @article.tags)
    else
      render json: json_response(RESPONSE_STATUS[:error]), status: :unprocessable_entity
    end
  end

  ##
  # Retrieve articles associated with a tag.
  #
  # @return [Array<Article>] a list of Articles associated with the tag.
  def retreive_articles
    @tag      = Tag.find(params[:tag_id])
    @articles = @tag.articles
    render json: json_response(RESPONSE_STATUS[:success], @articles)
  end

  private
  def tag_params
    params.permit(:name)
  end
end
