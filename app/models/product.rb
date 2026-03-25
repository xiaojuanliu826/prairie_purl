class Product < ApplicationRecord
  # a product can have multiple categories
  has_many :product_categories

  # associate with categories through the join table
  has_many :categories, through: :product_categories

  # validate: ensure name is present
  validates :name, presence: true

  # validate: price must be present
  validates :price, presence: true
end