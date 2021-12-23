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
        render json: @submit_status
    end

    def create
        @article = Article.find(params[:article_id])
        @comment = @article.comments.create(comment_params)
        redirect_to article_path(@article)
    end

    def destroy
        @article = Article.find(params[:article_id])
        @comment = @article.comments.find(params[:id])
        @comment.destroy
        redirect_to article_path(@article)
    end

    private
        def comment_params
            # set the initial status to SUBMITTED for new comments
            params
                .require(:comment)
                .permit(:commenter, :body, :status)
                .merge(submit_status: SUBMIT_STATUSES[:SUBMITTED])
        end
end
