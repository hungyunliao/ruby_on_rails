class Article < ApplicationRecord
    include Visible

    validates_uniqueness_of :title

    has_many :comments, dependent: :destroy

    validates :title, presence: true
    validates :body, presence: true, length: { minimum: 10 }
end
