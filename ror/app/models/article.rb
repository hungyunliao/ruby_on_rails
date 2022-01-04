class Article < ApplicationRecord
    include Visible

    validates_uniqueness_of :title

    has_many :comments, dependent: :destroy

    # Many-to-many relation to Tag through Tagging
    has_many :taggings, dependent: :destroy
    has_many :tags, :through => :taggings

    validates :title, presence: true
    validates :body, presence: true, length: { minimum: 10 }
end
