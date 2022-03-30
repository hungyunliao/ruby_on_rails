require 'rails_helper'

RSpec.describe CommentStatusCheckWorker, type: :worker do
  describe '#perform' do
    let(:article) { create(:article) }

    context 'with a body that contains bad words' do
      let(:comment) { @comment = create(:comment, body: 'comment body worse', commenter: 'comment commenter', article_id: article.id) }

      before do
        CommentStatusCheckWorker.new.perform(comment.id)
        comment.reload
      end

      it('flags the comment') { expect(comment.submit_status).to eq('flagged') }
    end

    context 'with a body that does not contain bad words' do
      let(:comment) { @comment = create(:comment, body: 'comment body good', commenter: 'comment commenter', article_id: article.id) }

      before do
        CommentStatusCheckWorker.new.perform(comment.id)
        comment.reload
      end

      it('approves the comment') { expect(comment.submit_status).to eq('approved') }
    end
  end
end
