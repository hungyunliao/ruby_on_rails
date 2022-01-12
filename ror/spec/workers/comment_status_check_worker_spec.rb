require 'rails_helper'

RSpec.describe CommentStatusCheckWorker, type: :worker do
  describe '.perform' do
    let(:article) do
      @article = Article.new(title: 'article title', body: 'article body', status: 'public')
      @article.save
      @article
    end

    context 'with a body that contains bad words' do
      let(:comment) do
        @comment = article.comments.create(body: 'comment body worse', commenter: 'comment commenter')
        @comment.save

        CommentStatusCheckWorker.new.perform(@comment.id)

        @comment = Comment.find(@comment.id)
      end


      it('flags the comment') { expect(comment.submit_status).to eq('flagged') }
    end

    context 'with a body that does not contain bad words' do
      let(:comment) do
        @comment = article.comments.create(body: 'comment body good', commenter: 'comment commenter')
        @comment.save

        CommentStatusCheckWorker.new.perform(@comment.id)

        @comment = Comment.find(@comment.id)
      end

      it('approves the comment') { expect(comment.submit_status).to eq('approved') }
    end
  end
end
