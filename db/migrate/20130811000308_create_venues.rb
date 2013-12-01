class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name, :limit => 70
      t.string :address, :limit => 70
      t.float :latitude
      t.float :longitude

      t.references :host

      t.timestamps
    end

    add_index :venues, :latitude, :null => false
    add_index :venues, :longitude, :null => false
  end
end