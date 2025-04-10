class AddLockVersionToModels < ActiveRecord::Migration[7.1]
  def change
    add_column :user_follows, :lock_version, :integer
    add_column :users, :lock_version, :integer
  end
end
