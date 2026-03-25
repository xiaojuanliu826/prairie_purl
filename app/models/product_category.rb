class ProductCategory < ApplicationRecord
  belongs_to :product
  belongs_to :category

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "id", "product_id", "updated_at"]
  end

  # 如果以后报错说需要 associations，也顺便加上这个
  def self.ransackable_associations(auth_object = nil)
    ["category", "product"]
  end
end
