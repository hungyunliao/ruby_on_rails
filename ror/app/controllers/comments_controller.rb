class CommentsController < BaseController

  SUBMIT_STATUS = {
    submitted: 'submitted',
    approved:  'approved',
    flagged:   'flagged'
  }

  ##
  # Fetch all comments. An optional url params 'status' [String] can be included in the request.
  # If the 'status' params is included, this action will return all comments with the status given, otherwise, it returns all the comments
  # with the status 'approved'.
  #
  # @return [Array<Article>] a list of Articles.
  def index
    @article        = Article.find(params[:article_id])
    @submit_status  = params['status'] && SUBMIT_STATUS.values.include?(params['status']) ? params['status'] : SUBMIT_STATUS[:approved]
    @comments       = @article.comments.where("submit_status = '#{@submit_status}'")
    render json: ActiveModelSerializers::SerializableResource.new(@comments, each_serializer: CommentSerializer).as_json
  end

  ##
  # Fetch certain comment by id.
  #
  # @return [Comment] the comment object.
  def show
    @comment = Comment.find(params[:id])
    render json: ActiveModelSerializers::SerializableResource.new(@comment, serializer: CommentSerializer).as_json
  end

  ##
  # Create a comment and associate it with an article. All newly created comment's submit_status is defaulted to 'submitted' and will be queued up
  # as a Sidekiq job, which will be processed in parallel by CommentStatusCheckWorker (bad words checker) and the submit_status will be updated.
  #
  # @return [Comment] the comment object.
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)

    if @comment.save
      CommentStatusCheckWorker.perform_async(@comment.id)
      render json: ActiveModelSerializers::SerializableResource.new(@comment, serializer: CommentSerializer).as_json
    else
      render json: ActiveModelSerializers::SerializableResource.new(@comment, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Update a comment. Everytime a comment is updated, the submit_status will be reset to 'submitted' and the Sidekiq process will be
  # triggered again.
  #
  # @return [Comment] the comment object being updated.
  def update
    @comment = Comment.find(params[:id])

    if @comment.update(comment_params)
      CommentStatusCheckWorker.perform_async(@comment.id)
      render json: ActiveModelSerializers::SerializableResource.new(@comment, serializer: CommentSerializer).as_json
    else
      render json: ActiveModelSerializers::SerializableResource.new(@comment, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Destroy a comment.
  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy

    if @comment.destroyed?
      render json: {}, status: :no_content
    else
      render json: ActiveModelSerializers::SerializableResource.new(@comment, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params
      .require(:comment)
      .permit(:commenter, :body)
      .merge(submit_status: SUBMIT_STATUS[:submitted])
  end
end
