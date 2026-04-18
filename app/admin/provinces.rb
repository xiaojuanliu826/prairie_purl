ActiveAdmin.register Province do

  menu parent: "Settings", priority: 2, label: "Provinces"
  permit_params :name, :gst, :pst, :hst

  form do |f|
    f.inputs "Province Details" do
      f.input :name
      # 显式指定 input_html，避免 Formtastic 报错
      f.input :gst, input_html: { min: 0, step: 0.001 }
      f.input :pst, input_html: { min: 0, step: 0.001 }
      f.input :hst, input_html: { min: 0, step: 0.001 }
    end
    f.actions
  end

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
