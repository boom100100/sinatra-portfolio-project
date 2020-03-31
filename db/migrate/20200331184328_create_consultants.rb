class CreateConsultants < ActiveRecord::Migration[5.2]
  def change
    create_table :consultants do |t|
      t.string :email
      t.boolean :admin
      t.string :password_digest
    end
  end
end
