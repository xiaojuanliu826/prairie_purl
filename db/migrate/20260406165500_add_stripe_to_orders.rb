class AddStripeToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :stripe_id, :string
  end
end
