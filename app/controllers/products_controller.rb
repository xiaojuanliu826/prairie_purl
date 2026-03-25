class ProductsController < ApplicationController
  # GET /products
  def index
    # 1. Initialize the base scope with optimizations
    # .with_attached_image: Prevents N+1 queries for ActiveStorage blobs
    # .includes(:categories): Prevents N+1 queries for associated categories
    # .distinct: Ensures unique product records when using JOINs
    @products = Product.with_attached_image.includes(:categories).distinct

    # 2. Filter by Keyword (Name or Description)
    # We specify "products.name" to avoid ambiguity with "categories.name"
    if params[:keyword].present?
      search_term = "%#{params[:keyword]}%"
      @products = @products.where(
        "products.name LIKE ? OR products.description LIKE ?",
        search_term,
        search_term
      )
    end

    # 3. Filter by Category
    # Joins the product_categories join table to filter by specific category ID
    if params[:category_id].present?
      @products = @products.joins(:categories).where(categories: { id: params[:category_id] })
    end

    # 4. Filter by Status (On Sale or New Arrivals)
    # This handles the custom filters from the navigation bar
    if params[:filter] == "on_sale"
      @products = @products.where(on_sale: true)
    elsif params[:filter] == "new"
      # Filters products created within the last 3 days
      @products = @products.where("products.created_at >= ?", 3.days.ago)
    end

    # 5. Pagination
    # Using Kaminari to limit results per page
    @products = @products.page(params[:page]).per(10)

    # 6. Data for View Components
    # Fetches all categories for the search dropdown menu
    @categories = Category.all
  end

  # GET /products/:id
  def show
    @product = Product.find(params[:id])
  end
end