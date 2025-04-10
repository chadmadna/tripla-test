class CreateUserFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :user_follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :following, null: false, foreign_key: { to_table: :users }
      t.datetime :discarded_at
      t.index :discarded_at
      t.index [:follower_id, :following_id], unique: true
      t.timestamps
    end
  end
end
