class PagesController < ApplicationController
  def show
  # 使用 capitalize 确保无论用户输入 about 还是 About，都会变成 "About" 去查询
    @page = Page.find_by!(title: params[:title].capitalize)
    rescue ActiveRecord::RecordNotFound
  # 如果还是找不到，跳转回首页并提示
    redirect_to root_path, alert: "Page not found."
  end
end
