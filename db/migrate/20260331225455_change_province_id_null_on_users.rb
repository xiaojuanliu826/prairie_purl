class ChangeProvinceIdNullOnUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :province_id, true
  end
end
