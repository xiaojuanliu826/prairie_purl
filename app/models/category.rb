class Category < ApplicationRecord
  # a category has multiple products
  has_many :product_categories, dependent: :destroy

  has_many :products, through: :product_categories

  # ensure category name is present
  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
  ["name", "created_at", "updated_at"]
  end

  # 允许搜索的关联（修复当前报错的关键）
  def self.ransackable_associations(auth_object = nil)
    ["product_categories", "products"]
  end


  def display_name
  self.name
  end
end