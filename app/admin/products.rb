ActiveAdmin.register Product do
  # 1. all allowed parameters
  permit_params :name, :description, :price, :on_sale, :image, category_ids: []

  # 2. exclude the :image from filters to prevent errors
  filter :name
  filter :categories, as: :select, collection: -> { Category.all }
  filter :price
  filter :on_sale
  filter :created_at

  # 3. index page (fix image error)
  index do
    selectable_column
    id_column
    column :name
    column :price
    column :on_sale
    # add image thumbnail (if attached)
    column :image do |product|
      if product.image.attached?
        image_tag product.image.variant(resize_to_limit: [50, 50])
      end
    end
    column :categories do |product|
      product.categories.map(&:name).join(", ")
    end
    actions
  end

  # 4. form configuration (with image upload and category selection)
  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :on_sale
      # image upload with preview (if already attached)
      f.input :image, as: :file, hint: f.object.image.attached? ? image_tag(f.object.image.variant(resize_to_limit: [100, 100])) : content_tag(:span, "No image uploaded")
    end

    f.inputs "Associations" do
      # checkboxes for categories (allow multiple selection)
      f.input :category_ids, as: :check_boxes, collection: Category.all, label: "Categories"
    end
    f.actions
  end

  # 5. show page configuration (display image and categories)
  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :on_sale
      row :image do |product|
        if product.image.attached?
          image_tag product.image.variant(resize_to_limit: [200, 200])
        else
          "No image uploaded"
        end
      end
      row :categories do |product|
        product.categories.map(&:name).join(", ")
      end
    end
    active_admin_comments
  end
end