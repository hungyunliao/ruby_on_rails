class AddArticlesCountToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :articles_count, :integer
  end
end
