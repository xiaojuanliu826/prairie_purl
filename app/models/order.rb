class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  validates :address, :city, presence: true
  STATUSES = ["new", "paid", "shipped"]

  validates :status, inclusion: { in: STATUSES }

  def self.ransackable_attributes(auth_object = nil)
    ["address", "city", "created_at", "gst", "hst", "id", "pst", "status", "stripe_id", "total_amount", "updated_at", "user_id"]
  end

  # 允许 ActiveAdmin 搜索的关联
  def self.ransackable_associations(auth_object = nil)
    ["order_items", "products", "user", "province"]
  end
end
