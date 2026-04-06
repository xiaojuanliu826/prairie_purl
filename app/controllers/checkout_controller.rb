class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty, only: [:create]

  def show
    prepare_checkout_data
    # 只要这三个字段任何一个为空，就判定为需要地址
    @needs_address = current_user.address.blank? || current_user.city.blank? || current_user.province_id.nil?
  end

  def update_address
    if current_user.update(user_params)
      redirect_to checkout_path, notice: "Address updated! Now reviewing your invoice."
    else
      # 失败时重新加载数据，防止 View 因为找不到变量而报错
      prepare_checkout_data
      @needs_address = true
      flash.now[:alert] = "Update failed: #{current_user.errors.full_messages.join(', ')}"
      render :show, status: :unprocessable_entity
    end
  end

  def create
    # 1. 地址检查
    if current_user.address.blank? || current_user.city.blank? || current_user.province_id.nil?
      redirect_to checkout_path, alert: "Please provide your full shipping address before confirming."
      return
    end

    @cart = session[:cart] || {}
    # 这里不需要判断 @cart.empty? 了，因为你顶部有 before_action :ensure_cart_not_empty

    # 注意：我们将所有逻辑包裹在一个 begin...rescue 块内
    begin
      ActiveRecord::Base.transaction do
        # 2. 创建订单
        @order = current_user.orders.create!(
          gst: current_user.province&.gst || 0,
          pst: current_user.province&.pst || 0,
          hst: current_user.province&.hst || 0,
          address: current_user.address,
          city: current_user.city,
          status: "new",
          total_amount: 0
        )

        line_items_for_stripe = []
        running_subtotal = 0

        # 3. 遍历购物车
        @cart.each do |product_id, quantity|
          product = Product.find(product_id)
          item_price = product.price

          @order.order_items.create!(
            product: product,
            quantity: quantity,
            price: item_price
          )

          running_subtotal += item_price * quantity.to_i

          line_items_for_stripe << {
            price_data: {
              currency: "cad",
              product_data: { name: product.name },
              unit_amount: (item_price * 100).to_i
            },
            quantity: quantity.to_i
          }
        end

        # 4. 更新总额
        tax_rate = @order.gst + @order.pst + @order.hst
        total_with_tax = running_subtotal * (1 + tax_rate)
        @order.update!(total_amount: total_with_tax)

        # 5. Stripe Session
        # ⚠️ 请确认路由是 success_checkout_url 还是 success_checkouts_url
        stripe_session = Stripe::Checkout::Session.create(
          payment_method_types: ["card"],
          line_items: line_items_for_stripe,
          mode: "payment",
          success_url: success_checkout_url(order_id: @order.id),
          cancel_url: cart_url
        )

        @order.update!(stripe_id: stripe_session.id)

        # 6. 跳转
        redirect_to stripe_session.url, allow_other_host: true
      end

    rescue Stripe::StripeError => e
      redirect_to cart_path, alert: "Stripe Error: #{e.message}"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to cart_path, alert: "Order failed: #{e.message}"
    rescue StandardError => e
      redirect_to cart_path, alert: "Something went wrong: #{e.message}"
    end
  end # create 的真正结束位置

  def success
    @order = current_user.orders.find_by(id: params[:order_id])
    if @order
    @order.update(status: "paid")
    session[:cart] = {} # 支付成功，清空购物车
    else
    redirect_to root_path, alert: "Order not found."
    end
  end

  def cancel
  # 用户取消支付时的逻辑，通常直接渲染个页面或跳回购物车
    redirect_to cart_path, alert: "Payment was cancelled."
  end

  private

  # 所有私有辅助方法统一放这里
  def prepare_checkout_data
    session[:cart] ||= {}
    product_ids = session[:cart].keys
    @products = Product.where(id: product_ids)

    @subtotal = @products.sum { |p| p.price * session[:cart][p.id.to_s].to_i }

    if current_user.province
      p = current_user.province
      @gst = @subtotal * p.gst
      @pst = @subtotal * p.pst
      @hst = @subtotal * p.hst
    else
      @gst = @pst = @hst = 0
    end

    @total = @subtotal + @gst + @pst + @hst
  end

  def ensure_cart_not_empty
    if session[:cart].blank?
      redirect_to root_path, alert: "Your cart is empty!"
    end
  end

  def user_params
    params.require(:user).permit(:address, :city, :province_id)
  end
end