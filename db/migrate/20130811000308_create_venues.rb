class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
    	t.string :name, :limit => 70
      t.string :address, :limit => 70
      t.float :latitude
      t.float :longitude
      t.integer :user_id

      t.timestamps
    end

    add_index :venues, :user_id, :null => false
    add_index :venues, :latitude, :null => false
    add_index :venues, :longitude, :null => false
  end
end
