class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :limit => 70
      t.string :venue, :limit => 70
      t.string :address, :limit => 70
      t.text :details
      t.boolean :fav, :default => false
      t.time :start_time
      t.time :end_time
      t.date :date
      t.decimal :cost, :precision => 6, :scale => 2

      t.timestamps
    end
  end
end
