class AddAddressToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_reference :users, :province, null: false, foreign_key: true
  end
end
