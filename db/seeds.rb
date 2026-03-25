require 'faker'

# 1. clears old data (optional, if you want a clean slate each time)
# Product.destroy_all

# 2. create an admin user for ActiveAdmin (only in development)
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end if Rails.env.development?

# 3. create some categories
category_names = ["Knitwear", "Earrings", "Necklaces", "Sale"]
categories = category_names.map do |name|
  Category.find_or_create_by!(name: name)
end

# 4. create 100 products with random data and assign categories
100.times do
  product = Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph,
    price: Faker::Commerce.price(range: 10..200),
    on_sale: [true, false].sample
  )

  # random assignment of 1 to 2 categories
  product.categories << categories.sample(rand(1..2))
end

puts "Seed completed: Created 100 products and assigned categories."