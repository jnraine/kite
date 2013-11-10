class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
    	t.date :date
      t.integer :event_id

      t.timestamps
    end

    add_index :days, :date, :null => false
		add_index :days, :event_id, :null => false
  end
end