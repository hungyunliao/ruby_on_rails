class AddDefaultValueToCounterAttribute < ActiveRecord::Migration[6.1]
  def up
    change_column :tags, :taggings_count, :integer, default: 0
  end
  
  def down
    change_column :tags, :taggings_count, :integer, default: 0
  end
end
