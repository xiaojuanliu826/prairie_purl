ActiveAdmin.register Province do

  permit_params :name, :gst, :pst, :hst
  filter :name
  filter :gst
  filter :pst
  filter :hst
  filter :created_at
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :gst, :pst, :hst
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :gst, :pst, :hst]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
