class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

   helper_method :current_user, :logged_in?, :owns?

  private

  def owns?(record)
    current_user && (record.user_id == current_user.id || current_user.admin?)
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?
    redirect_to login_path, alert: "Login to continue"
  end
end
