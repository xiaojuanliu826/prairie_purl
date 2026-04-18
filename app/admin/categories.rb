ActiveAdmin.register Category do

  menu parent: "Settings", priority: 1, label: "Categories"
  permit_params :name

end
