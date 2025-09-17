class CreateUfValues < ActiveRecord::Migration[8.0]
  def change
    create_table :uf_values do |t|
      #time and value for uf cant be blank.
      t.date :uf_date, null: false
      t.decimal :uf_value, null: false

      t.timestamps
    end
    #added index for date, will be a recurring query
    add_index :uf_values, :uf_date, unique: true
  end
end
