class FollowsController < ApplicationController
  before_action :require_login
  before_action :set_user

  def create
    if @user == current_user
      return redirect_back fallback_location: @user, alert: "You cannot follow yourself."
    end

    current_user.follow!(@user)
    redirect_back fallback_location: @user, notice: "You are now following #{@user.name}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: @user, alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    current_user.unfollow!(@user)
    redirect_back fallback_location: @user, notice: "You unfollowed #{@user.name}."
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
