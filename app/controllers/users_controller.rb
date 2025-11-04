class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :scrub_blank_passwords, only: :update

  def index
    @query = params[:q].to_s.strip
    scope = User.order(created_at: :desc)
    scope = scope.where("users.name ILIKE :q OR users.email ILIKE :q", q: "%#{@query}%") if @query.present?
    @users = scope.limit(50)
  end

  def show
    @recent_posts = @user.posts.order(created_at: :desc).limit(5)
    @recent_comments = @user.comments.includes(:post).order(created_at: :desc).limit(5)
    @recent_likes = @user.likes.includes(:likeable).order(created_at: :desc).limit(5)
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!
    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :bio)
  end

  def scrub_blank_passwords
    return unless params[:user]

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
  end
end
