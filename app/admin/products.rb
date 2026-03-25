ActiveAdmin.register Product do

  # permit_params: allowed parameters (security)
  permit_params :name, :description, :price, :on_sale, category_ids: []

  # form: the form for creating/editing products (crucial)
  form do |f|
    f.inputs do
      f.input :name        # product name
      f.input :description # description
      f.input :price       # price
      f.input :on_sale     # is on sale

      # multi-select category
      f.input :categories, as: :check_boxes
    end
    f.actions
  end

end