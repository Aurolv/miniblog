class LikesController < ApplicationController
  before_action :require_login
  before_action :set_likeable

  def create
    return if performed?

    @likeable.likes.find_or_create_by!(user: current_user)
    respond_to do |f|
      f.turbo_stream { render turbo_stream: replace_like_frame(@likeable) }
      f.html         { redirect_back fallback_location: @post }
    end
  end

  def destroy
    return if performed?

    @likeable.likes.find(params[:id]).destroy
    respond_to do |f|
      f.turbo_stream { render turbo_stream: replace_like_frame(@likeable) }
      f.html         { redirect_back fallback_location: @post }
    end
  end

  private

  def set_likeable
    @likeable =
      if params[:post_id]
        Post.find(params[:post_id])
      elsif params[:comment_id]
        Comment.find(params[:comment_id])
      end

    @post = @likeable.is_a?(Post) ? @likeable : @likeable&.post
    head :not_found unless @likeable
  end

  def require_login
    redirect_to login_path, alert: "Please log in" unless current_user
  end

  def replace_like_frame(likeable)
    likeable.reload

    turbo_stream.replace(
      helpers.dom_id(likeable, :like),
      partial: likeable_partial(likeable),
      locals: likeable_locals(likeable)
    )
  end

  def likeable_partial(likeable)
    likeable.is_a?(Post) ? "likes/like_button" : "likes/comment_like_button"
  end

  def likeable_locals(likeable)
    likeable.is_a?(Post) ? { post: likeable } : { comment: likeable }
  end
end
