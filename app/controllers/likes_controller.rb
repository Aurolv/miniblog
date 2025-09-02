class LikesController < ApplicationController
  before_action :require_login
  before_action :set_post

  def create
    @post.likes.find_or_create_by!(user: current_user)
    respond_to do |f|
      f.turbo_stream { render turbo_stream: replace_like_frame(@post) }
      f.html         { redirect_to @post }
    end
  end

  def destroy
    @post.likes.find(params[:id]).destroy
    respond_to do |f|
      f.turbo_stream { render turbo_stream: replace_like_frame(@post) }
      f.html         { redirect_to @post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def require_login
    redirect_to login_path, alert: "Please log in" unless current_user
  end

  def replace_like_frame(post)
    turbo_stream.replace(
      helpers.dom_id(post, :like),
      partial: "likes/like_button",
      locals: { post: post }
    )
  end
end
