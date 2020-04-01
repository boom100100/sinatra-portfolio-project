class CreateTickets < ActiveRecord::Migration[5.2]
  def change

    create_table :tickets do |t|
      t.string :name
      t.string :details
      t.boolean :complete
      t.integer :client_id
      t.integer :consultant_id

      t.timestamps
    end
  end
end
