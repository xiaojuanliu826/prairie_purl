class ProductsController < ApplicationController
  def index
    # get keyword from params
    keyword = params[:keyword]

    # get category_id（from dropdown）
    category_id = params[:category_id]

    # initial scope：all products (before filtering)
    @products = Product.all

    # 🔍 keyword search（name 或 description）
    if keyword.present?
      @products = @products.where(
        "products.name LIKE ? OR products.description LIKE ?",
        "%#{keyword}%",
        "%#{keyword}%"
      )
    end

    # 📂 category filtering（if category is selected）
    if category_id.present?
      @products = @products.joins(:categories)
                           .where(categories: { id: category_id })
    end

    # 📄 pagination
    @products = @products.page(params[:page]).per(10)

    # for dropdown
    @categories = Category.all
  end

  def show
    @product = Product.find(params[:id])
  end
end
