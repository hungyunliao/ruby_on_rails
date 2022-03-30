class CommentStatusCheckWorker
  include Sidekiq::Worker

  BAD_WORDS = [ "bad", "worse", "worst", "terrible" ]

  def perform(comment_id)
    @comment = Comment.find(comment_id)
    @comment_body = @comment.body

    BAD_WORDS.each do |bad_word|
      if @comment_body.include? bad_word
        @comment.update(:submit_status => "flagged")
        return
      end
    end
    
    @comment.update(:submit_status => "approved")
  end
end
