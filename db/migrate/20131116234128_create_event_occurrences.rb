class CreateEventOccurrences < ActiveRecord::Migration
  def change
    create_table :event_occurrences do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :event
      t.timestamps
    end
  end
end
