class AddSubmitStatusToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :submit_status, :string
  end
end
