class TagsController < ApplicationController
  include JsonResponse

  def index
    @filter = params['filter']
    @tags   = @filter ? Tag.where('name LIKE ?', "%#{@filter}%") : Tag.all
    render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @tags)
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @tag)
    else
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], @tag.errors)
    end
  end

  def update
    # find_by() returns nil if nothing found. find() raises an exception.
    @tag = Tag.find_by(id: params[:id])

    if !@tag
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Tag not found.')
      return
    end

    if @tag.update(tag_params)
      render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @tag)
    else
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Fail to update the tag.')
    end
  end

  def destroy
    @tag = Tag.find_by(id: params[:id])

    if !@tag
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Tag not found.')
      return
    end

    if @tag.taggings_count == 0
      @tag.destroy
      render json: json_response(JsonResponse::RESPONSE_STATUS[:success])
    else
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Cannot delete the tag.')
    end
  end

  #
  # Nested endpoints
  #
  def article_tags
    @article = Article.find_by(id: params[:article_id])

    if !@article
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Article not found.')
      return
    end

    render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @article.tags)
  end

  def attach_tag
    @article = Article.find_by(id: params[:article_id])
    @tag     = Tag.find(params[:tag_id])

    if !@article || !@tag
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Article or Tag not found.')
      return
    end

    begin
      @article.tags << @tag
      render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @article.tags)
    rescue ActiveRecord::RecordInvalid => error
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Tag already attached.')
    end
  end

  def detach_tag
    @article = Article.find_by(id: params[:article_id])
    @tag     = Tag.find_by(id: params[:id])

    if !@article || !@tag
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Article or Tag not found.')
      return
    end

    @target_tag_id = params[:id].to_i   # Convert params[:id] from String to Integer

    @article.tags.each do |tag|
      if tag.id == @target_tag_id
        @article.tags.delete(tag)
      end
    end
    render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @article.tags)
  end

  def retreive_articles
    @tag = Tag.find_by(id: params[:tag_id])

    if !@tag
      render json: json_response(JsonResponse::RESPONSE_STATUS[:error], 'Tag not found.')
      return
    end

    @articles = @tag.articles
    render json: json_response(JsonResponse::RESPONSE_STATUS[:success], @articles)
  end

  private
    def tag_params
      params.permit(:name)
    end

    def json_response(status, message = '')
      {
        status:   status,
        message:  message
      }
    end
end
