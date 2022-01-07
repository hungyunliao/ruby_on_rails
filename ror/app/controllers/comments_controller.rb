class CommentsController < ApplicationController

  SUBMIT_STATUSES = {
    :SUBMITTED => 'submitted',
    :APPROVED => 'approved',
    :FLAGGED => 'flagged',
  }

  def index
    @article = Article.find(params[:article_id])
    @submit_status = params["status"] && SUBMIT_STATUSES.values.include?(params["status"]) ? params["status"] : "approved"
    @comments = @article.comments.where("submit_status = '#{@submit_status}'")
    render json: @comments
  end

  def show
    @comment = Comment.find(params[:id])
    render json: @comment
  end

  def new
    @comment = Comment.new
    render json: @comment
  end

  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    CommentStatusCheckWorker.perform_async(@comment.id)
    render json: @comment
  end

  def edit
    @article = Article.find(params[:article_id])
    @comments = @article.comments
    render json: @comments
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      CommentStatusCheckWorker.perform_async(@comment.id)
      render json: @comment
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def comment_params
      # Either CREATE or UPDATE, we always need to set the submit_status to "submitted".
      params
        .permit(:commenter, :body, :status)
        .merge(submit_status: SUBMIT_STATUSES[:SUBMITTED])
    end
end
