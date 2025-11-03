class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: :create
  before_action :set_comment, only: :destroy
  before_action :authorize_owner!, only: :destroy

  def create
    @comment = @post.comments.new(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to @post, notice: "Comment was successfully created."
    else
      redirect_to @post, alert: "Comment could not be saved.", status: :unprocessable_entity
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
    params.require(:comment).permit(:body)
  end
end
