class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.string :stripe_customer_id
      t.references :attending, index: true
      t.belongs_to :event, index: true
      t.timestamps
    end
  end
end
