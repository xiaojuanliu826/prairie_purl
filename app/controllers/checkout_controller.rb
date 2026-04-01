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
    # 二重检查：防止绕过前端直接提交
    if current_user.address.blank? || current_user.city.blank? || current_user.province_id.nil?
      redirect_to checkout_path, alert: "Please provide your full shipping address before confirming."
      return
    end

    ActiveRecord::Base.transaction do
      # 1. 创建订单（保存当前税率和地址快照）
      @order = current_user.orders.create!(
        gst: current_user.province&.gst || 0,
        pst: current_user.province&.pst || 0,
        hst: current_user.province&.hst || 0,
        address: current_user.address, # 保存下单瞬间的地址
        city: current_user.city,
        total_amount: 0,# 保存下单瞬间的城市
        status: "pending"
      )

      running_subtotal = 0

      # 2. 创建订单项
      session[:cart].each do |product_id, quantity|
        product = Product.find(product_id)
        item_price = product.price

        @order.order_items.create!(
          product: product,
          quantity: quantity,
          price: item_price
        )

        running_subtotal += item_price * quantity.to_i
      end

      # 3. 计算并更新总额（含税）
      tax_amount = running_subtotal * (@order.gst + @order.pst + @order.hst)
      @order.update!(total_amount: running_subtotal + tax_amount)

      # 4. 完成
      session[:cart] = {}
      redirect_to root_path, notice: "Order ##{@order.id} placed successfully! Total: #{helpers.number_to_currency(@order.total_amount)}"
    end

  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path, alert: "Order failed: #{e.message}"
  rescue StandardError => e
    redirect_to cart_path, alert: "Something went wrong. Please try again."
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