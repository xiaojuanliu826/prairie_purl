ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: "Business Overview" do
    # 第一排：数据看板
    columns do
      column do
        panel "Total Sales" do
          h2 number_to_currency(Order.where(status: 'paid').sum(:total_amount))
        end
      end
      column do
        panel "Pending Orders" do
          h2 Order.where(status: 'paid').count # 假设 paid 代表需要发货
        end
      end
      column do
        panel "Active Products" do
          h2 Product.count
        end
      end
    end

    # 第二排：最近订单和新用户
    columns do
      column span: 2 do
        panel "Recent Paid Orders" do
          table_for Order.where(status: 'paid').order(created_at: :desc).limit(5) do
            column("Order #") { |order| link_to "Order ##{order.id}", admin_order_path(order) }
            column(:user)
            column(:total_amount) { |order| number_to_currency(order.total_amount) }
            column(:created_at)
          end
        end
      end

      column do
        panel "System Info" do
          para "Welcome, #{current_admin_user.email}!"
          para "Today is: #{Time.current.strftime('%B %d, %Y')}"
          hr
          div do
            link_to "View Store Front", root_path, target: "_blank", class: "button"
          end
        end
      end
    end
  end
end