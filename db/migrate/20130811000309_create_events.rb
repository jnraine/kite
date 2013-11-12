class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :limit => 70
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :end_date
      t.text :details
      t.decimal :cost, :precision => 6, :scale => 2
      t.integer :venue_id
      t.integer :user_id
      t.text :schedule

      t.timestamps
    end

    add_index :events, :user_id, :null => false
    add_index :events, :venue_id, :null => false
    add_index :events, :start_time, :null => false
    add_index :events, :end_time, :null => false
    add_index :events, :end_date
  end
end