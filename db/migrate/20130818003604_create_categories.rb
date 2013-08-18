class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
    	t.string :name

      t.timestamps
    end

    add_column :events, :category_id, :integer
    add_index :events, :category_id, :null => false
  end
end
