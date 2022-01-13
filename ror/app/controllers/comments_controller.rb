class CommentsController < BaseController

  ##
  # Fetch all comments. An optional url params 'status' [String] can be included in the request.
  # If the 'status' params is included, this action will return all comments with the status given, otherwise, it returns all the comments with the status
  # 'approved'.
  def index
    article        = Article.find(params[:article_id])
    submit_status  = params['status'] && Comment::SUBMIT_STATUS.values.include?(params['status']) ? params['status'] : Comment::SUBMIT_STATUS[:approved]
    comments       = article.comments.with_status(submit_status)
    render json: comments
  end

  ##
  # Fetch certain comment by id.
  def show
    comment = Comment.find(params[:id])
    render json: comment
  end

  ##
  # Create a comment and associate it with an article. All newly created comment's submit_status is defaulted to 'submitted' and will be queued up as a Sidekiq
  # job, which will be processed in parallel by CommentStatusCheckWorker (bad words checker) and the submit_status will be updated.
  def create
    article = Article.find(params[:article_id])
    comment = article.comments.create(comment_params)

    if comment.save
      CommentStatusCheckWorker.perform_async(comment.id)
      render json: comment, status: :created
    else
      render json: ActiveModelSerializers::SerializableResource.new(comment, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Update a comment. Everytime a comment is updated, the submit_status will be reset to 'submitted' and the Sidekiq process will be triggered again.
  def update
    comment = Comment.find(params[:id])

    if comment.update(comment_params)
      CommentStatusCheckWorker.perform_async(comment.id)
      render json: comment
    else
      render json: ActiveModelSerializers::SerializableResource.new(comment, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  ##
  # Destroy a comment.
  def destroy
    article = Article.find(params[:article_id])
    comment = article.comments.find(params[:id])

    if comment.destroy
      render json: {}, status: :no_content
    else
      render json: ActiveModelSerializers::SerializableResource.new(comment, serializer: ErrorSerializer, adapter: :attributes).as_json,
                   status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params
      .require(:comment)
      .permit(:commenter, :body)
      .merge(submit_status: Comment::SUBMIT_STATUS[:submitted])
  end
end
