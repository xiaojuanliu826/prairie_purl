class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :province, optional: true
  has_many :orders

  validates :email, presence: true, uniqueness: true
  validates :is_admin, inclusion: { in: [true, false] }

  def display_name
    email # 或者你的用户名属性，比如 name
  end
end
