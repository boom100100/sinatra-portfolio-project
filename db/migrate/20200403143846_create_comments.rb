class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :ticket_id
      t.integer :client_id
      t.integer :consultant_id

      t.timestamps
    end
  end
end
