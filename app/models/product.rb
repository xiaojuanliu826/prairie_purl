class Product < ApplicationRecord

  has_one_attached :image
  # a product can have multiple categories
  has_many :product_categories, dependent: :destroy

  # associate with categories through the join table
  has_many :categories, through: :product_categories

  # validate: ensure name is present
  validates :name, presence: true

  # validate: price must be present
  validates :price, presence: true

  def self.ransackable_attributes(auth_object = nil)
  ["name", "description", "price", "on_sale", "created_at", "updated_at"]
  end

  # 允许通过分类来筛选产品
  def self.ransackable_associations(auth_object = nil)
    ["categories", "product_categories"]
  end
end