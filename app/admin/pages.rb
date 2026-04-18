ActiveAdmin.register Page do

  menu parent: "Website Content", priority: 1, label: "Static Pages"
  # all allowed parameters
  permit_params :title, :content

  form do |f|
    f.inputs do
      # title（About / Contact）
      f.input :title, as: :select, collection: ["About", "Contact"]

      # content（text）
      f.input :content
    end
    f.actions
  end

end