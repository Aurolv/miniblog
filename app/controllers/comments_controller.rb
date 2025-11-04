class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: :create
  before_action :set_comment, only: :destroy
  before_action :authorize_owner!, only: :destroy
  before_action :ensure_post_published, only: :create

  def create
    @comment = @post.comments.new(comment_params.except(:parent_id).merge(user: current_user))
    attach_parent!

    if @comment.save
      redirect_to @post, notice: "Comment was successfully created."
    else
      prepare_comment_resources
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy!
    redirect_to @comment.post, notice: "Comment was successfully destroyed.", status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def authorize_owner!
    head :forbidden unless owns?(@comment)
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def attach_parent!
    parent_id = comment_params[:parent_id].presence
    return unless parent_id

    @reply_target = @post.comments.find_by(id: parent_id)
    @comment.parent = @reply_target if @reply_target
  end

  def prepare_comment_resources
    @comments = @post.comments.includes(:user, :likes, replies: [ :user, :likes ]).roots.order(created_at: :asc)
    if @comment.parent
      @reply_target ||= @comment.parent
      @reply_comment = @comment
      @new_comment = Comment.new
    else
      @new_comment = @comment
    end
    @reply_comment ||= Comment.new
    @reply_comment.parent ||= @reply_target if @reply_target
  end

  def ensure_post_published
    return if @post.published?

    redirect_to @post, alert: "Drafts do not accept comments."
  end
end
