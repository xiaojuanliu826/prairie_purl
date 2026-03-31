class ApplicationController < ActionController::Base
  # 1. 保留原有配置（支持现代浏览器特性）
  allow_browser versions: :modern

  # 2. 只有在 Devise 相关页面（如注册、编辑资料）时才执行该动作
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # 3. 允许 Devise 处理额外的字段
  def configure_permitted_parameters
    # 注册时允许传入 address, city, province_id
    devise_parameter_sanitizer.permit(:sign_up, keys: [:address, :city, :province_id])

    # 修改个人资料时也允许传入这些字段
    devise_parameter_sanitizer.permit(:account_update, keys: [:address, :city, :province_id])
  end
end