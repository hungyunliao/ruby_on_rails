class RemoveArticlesCountFromTags < ActiveRecord::Migration[6.1]
  def change
    remove_column :tags, :articles_count, :integer
  end
end
