class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?, :owns?, :owner?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from StandardError, with: :render_internal_error unless Rails.env.development?

  private

  def owns?(record)
    current_user && (record.user_id == current_user.id || current_user.admin?)
  end

  def owner?(record)
    current_user && record.user_id == current_user.id
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

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: "Admins only."
  end

  def render_not_found(exception)
    @error_title = "Not found"
    @error_message = exception.message
    render "errors/error_page", status: :not_found, layout: "application"
  end

  def render_internal_error(exception)
    Rails.logger.error(exception.full_message)
    @error_title = "Something went wrong"
    @error_message = "An unexpected error occurred. Please try again or contact support."
    render "errors/error_page", status: :internal_server_error, layout: "application"
  end
end
