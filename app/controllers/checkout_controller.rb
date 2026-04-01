class CheckoutController < ApplicationController
  before_action :authenticate_user! # 确保用户已登录
  before_action :ensure_cart_not_empty, only: [:create]

  def show
    prepare_checkout_data
  end

  def create
    # 使用事务保证订单和订单项要么全部成功，要么全部失败
    ActiveRecord::Base.transaction do
      # 1. 创建订单头部信息（从用户省份获取即时税率）
      @order = current_user.orders.create!(
        gst: current_user.province&.gst || 0,
        pst: current_user.province&.pst || 0,
        hst: current_user.province&.hst || 0,
        status: "pending"
      )

      running_subtotal = 0

      # 2. 遍历购物车创建订单项
      session[:cart].each do |product_id, quantity|
        product = Product.find(product_id)
        item_price = product.price

        @order.order_items.create!(
          product: product,
          quantity: quantity,
          price: item_price # 锁定购买时的价格
        )

        running_subtotal += item_price * quantity.to_i
      end

      # 3. 计算最终总金额（小计 + 税费）
      tax_amount = running_subtotal * (@order.gst + @order.pst + @order.hst)
      @order.update!(total_amount: running_subtotal + tax_amount)

      # 4. 成功后清空购物车
      session[:cart] = {}

      redirect_to root_path, notice: "Order ##{@order.id} placed successfully! Total: #{helpers.number_to_currency(@order.total_amount)}"
    end

  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path, alert: "Order failed: #{e.message}"
  rescue StandardError => e
    # 捕捉其他异常，防止页面直接崩溃
    redirect_to cart_path, alert: "Something went wrong. Please try again."
  end

  private

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
end