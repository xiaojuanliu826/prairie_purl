ActiveAdmin.register Order do
  permit_params :status, :user_id, :total_amount, :gst, :pst, :hst, :address, :city
  form do |f|
    f.inputs "Order Details" do
      f.input :user, member_label: :email # 解决 User 显示乱码问题
      f.input :total_amount
      f.input :status, as: :select, collection: Order::STATUSES # 变成下拉框
      f.input :address
      f.input :city
      f.input :gst
      f.input :pst
      f.input :hst
     end
    f.actions
  end

  # 1. 修复 actions 块的语法
  index do
    selectable_column
    id_column
    column :user
    column :total_amount
    column :status

    # 在 ActiveAdmin 中，自定义动作通常写在 actions 块内，但语法稍有不同
    actions do |order|
      if order.status == "paid"
        # 2. 修复 Rails 7 的请求方法问题
        item "Mark Shipped", mark_shipped_admin_order_path(order),
             method: :put,
             class: "member_link",
             data: { confirm: "Are you sure?" }
      end
    end
  end

  member_action :mark_shipped, method: :put do
    resource.update(status: "shipped")
    redirect_to admin_orders_path, notice: "Order marked as shipped"
  end

  show do
    attributes_table do
      row :user
      row :status
      row :total_amount
      row :gst
      row :pst
      row :hst
      # 增加时间显示通常很有用
      row :created_at
    end

    # 3. 修复 panel 里的变量引用
    panel "Products" do
      # 这里应该用 resource.order_items 或者 order.order_items
      table_for resource.order_items do
        column :product
        column :quantity
        column "Unit Price" do |item|
          number_to_currency(item.price)
        end
        column "Subtotal" do |item|
          number_to_currency(item.price * item.quantity)
        end
      end
    end
  end
end # 确保只有一个结束符