class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :priority

      t.timestamps
    end
  end
end
