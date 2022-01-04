class Tag < ApplicationRecord

    validates_uniqueness_of :name

    # Many-to-many relation to Article through Tagging
    has_many :taggings, dependent: :destroy
    has_many :articles, :through => :taggings
end
