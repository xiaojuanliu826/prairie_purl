class Province < ApplicationRecord
  has_many :users

  # 验证
  validates :name, presence: true, uniqueness: true
  validates :pst, :gst, :hst, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil)
    [ "name", "gst", "pst", "hst", "created_at", "updated_at", "id" ]
  end

  # 2. 允许搜索的关联（如果你有 has_many :users 或 :orders）
  def self.ransackable_associations(auth_object = nil)
    [ "orders" ] # 如果你暂时没有关联，可以留空数组 []
  end
end
