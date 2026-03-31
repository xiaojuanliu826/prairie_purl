class CartController < ApplicationController

  # 🛒 显示购物车
  def show
    # 如果 cart 不存在就初始化
    session[:cart] ||= {}

    # 从 session 取出 product ids
    product_ids = session[:cart].keys

    # 查询数据库获取 product
    @products = Product.where(id: product_ids)

  end

  # ➕ 添加商品
  def add
    session[:cart] ||= {}

    product_id = params[:product_id].to_s

    # 如果已存在 → +1
    if session[:cart][product_id]
      session[:cart][product_id] += 1
    else
      session[:cart][product_id] = 1
    end

    redirect_to cart_path, notice: "Product added to cart"
  end

  # 🔄 更新数量
  def update
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i

    if quantity > 0
      session[:cart][product_id] = quantity
    else
      session[:cart].delete(product_id)
    end

    redirect_to cart_path, notice: "Cart updated"
  end

  # ❌ 删除商品
  def remove
    product_id = params[:product_id].to_s

    session[:cart].delete(product_id)

    redirect_to cart_path, notice: "Item removed"
  end

end