class AddAddressDetailsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :address, :string
    add_column :orders, :city, :string
  end
end
