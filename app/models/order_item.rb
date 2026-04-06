class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # 允许搜索的属性（根据报错信息提供的列表）
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "order_id", "price", "product_id", "quantity", "updated_at"]
  end

  # 允许通过关联进行搜索
  def self.ransackable_associations(auth_object = nil)
    ["order", "product"]
  end
end
