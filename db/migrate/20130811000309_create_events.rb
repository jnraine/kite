class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :limit => 70
      t.string :venue, :limit => 70
      t.string :address, :limit => 70
      t.text :details
      t.boolean :fav, :default => false
      t.datetime :start_time
      t.datetime :end_time
      t.date :date
      t.decimal :cost, :precision => 6, :scale => 2

      t.timestamps
    end
  end
end
