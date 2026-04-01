class Province < ApplicationRecord
  has_many :users

  # 验证
  validates :name, presence: true
end
