class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.datetime :start_date, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :duration,    null: false, default: 5
      t.string :title,        null: false, default: ""
      t.text :description,    null: false, default: ""
      t.integer :price,       null: false, default: 0
      t.string :location,     null: false, default: ""
      t.references :admin, index: true
      t.timestamps
    end
  end
end
