class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :limit => 70
      t.text :details
      t.datetime :start_time
      t.datetime :end_time
      t.date :date
      t.decimal :cost, :precision => 6, :scale => 2
      t.integer :venue_id
      t.integer :user_id

      t.timestamps
    end

    add_index :events, :user_id, :null => false
    add_index :events, :venue_id, :null => false
    add_index :events, :start_time
    add_index :events, :end_time
    add_index :events, :date
  end
end