class CategoriesController < ApplicationController

  def show
    @category = Category.find(params[:id])

    # all products in this category, paginated
    @products = @category.products.page(params[:page]).per(10)
  end

end