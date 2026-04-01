class Page < ApplicationRecord
  # limit title to only fixed pages (to prevent arbitrary creation)
  validates :title, presence: true, inclusion: { in: ["About", "Contact"] }
  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "id", "title", "updated_at"]
  end

  # 如果以后你还需要通过关联表搜索，可能还需要添加 ransackable_associations
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
