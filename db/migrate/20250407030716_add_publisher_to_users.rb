class AddPublisherToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :publisher, null: false
  end
end
