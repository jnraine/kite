class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :limit => 70
      t.decimal :cost, :precision => 6, :scale => 2
      t.text :details
      t.text :schedule_hash

      t.references :venue
      t.references :user
      t.references :category

      t.timestamps
    end
  end
end