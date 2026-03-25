class Page < ApplicationRecord
  # limit title to only fixed pages (to prevent arbitrary creation)
  validates :title, presence: true, inclusion: { in: ["About", "Contact"] }
end
