class Tagging < ApplicationRecord

  # Composite key uniqueness - (article_id, tag_id)
  validates_uniqueness_of :article_id, scope: :tag_id

  belongs_to :article
  belongs_to :tag, counter_cache: true
end
