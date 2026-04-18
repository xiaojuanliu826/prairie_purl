class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :address, :city, presence: true
  validates :pst_rate, :gst_rate, :hst_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  STATUSES = [ "new", "paid", "shipped" ]

  validates :status, inclusion: { in: STATUSES }
  validates :user_id, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "address", "city", "created_at", "gst", "hst", "id", "pst", "status", "stripe_id", "total_amount", "updated_at", "user_id" ]
  end

  # 允许 ActiveAdmin 搜索的关联
  def self.ransackable_associations(auth_object = nil)
    [ "order_items", "products", "user", "province" ]
  end
end
