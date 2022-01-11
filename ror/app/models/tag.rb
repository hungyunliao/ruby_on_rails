class Tag < ApplicationRecord

  validates_uniqueness_of :name

  # Many-to-many relation to Article through Tagging
  has_many :taggings, dependent: :destroy
  has_many :articles, :through => :taggings

  before_destroy :destroable_check

  def destroable_check
    return true if taggings_count == 0
    self.errors[:base] << "Cannot delete Tag. Tag being referenced."
    raise ActiveRecord::RecordNotDestroyed, :undestroyable
  end
end
