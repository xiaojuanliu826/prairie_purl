class Category < ApplicationRecord
  # a category has multiple products
  has_many :product_categories

  has_many :products, through: :product_categories

  # ensure category name is present
  validates :name, presence: true
end