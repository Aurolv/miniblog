class PostsController < ApplicationController
  before_action :require_login, only: [ :new, :create, :edit, :update, :destroy, :drafts, :publish, :unpublish ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :publish, :unpublish ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy, :publish, :unpublish ]
  before_action :authorize_view_for_draft!, only: :show

  # GET /posts or /posts.json
  def index
    @listing_scope = :published
    @sort = permitted_sort
    @posts = sorted_posts(Post.published.with_attached_image.includes(:user, :likes, :comments))
  end

  def drafts
    @listing_scope = :drafts
    @sort = "latest"
    @posts = current_user.posts.draft.with_attached_image.includes(:user, :likes, :comments).order(updated_at: :desc)
    render :index
  end

  def search
    scope = Post.published
    @posts = scope.search(params[:q]).order(published_at: :desc).page(params[:page]).per(10)
    render :index
  end

  def publish
    @post.update!(status: :published, published_at: Time.current)
    redirect_to @post, notice: "Published"
  end

  def unpublish
    @post.update!(status: :draft, published_at: nil)
    redirect_to drafts_posts_path, notice: "Draft status returned"
  end

  # GET /posts/1 or /posts/1.json
  def show
    load_comment_resources
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.new(post_params_with_publish_time)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    if @post.update(post_params_with_publish_time)
      redirect_to @post, notice: "Post was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post = @post = Post.with_attached_image.find(params[:id])

    def authorize_owner!; head :forbidden unless @post.user_id == current_user.id; end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :status, :image)
    end

    def post_params_with_publish_time
      attrs = post_params.to_h
      attrs["status"] == "published"? attrs["published_at"] ||= Time.current : attrs["published_at"] = nil

      attrs
    end

    def load_comment_resources
      return if @post.draft?

      @new_comment ||= Comment.new
    @reply_comment ||= Comment.new
    @reply_target ||= nil
    @comments = @post.comments.includes(:user, :likes, replies: [ :user, :likes ]).roots.order(created_at: :asc)
  end

    def authorize_view_for_draft!
      return unless @post.draft?

      unless current_user && current_user.id == @post.user_id
        redirect_to posts_path, alert: "You cannot access this draft."
      end
    end

    def permitted_sort
      %w[latest popular discussed].include?(params[:sort]) ? params[:sort] : "latest"
    end

    def sorted_posts(scope)
      case @sort
      when "popular"
        scope.left_outer_joins(:likes)
             .group("posts.id")
             .order(Arel.sql("COUNT(likes.id) DESC, COALESCE(posts.published_at, posts.created_at) DESC"))
      when "discussed"
        scope.left_outer_joins(:comments)
             .group("posts.id")
             .order(Arel.sql("COUNT(comments.id) DESC, COALESCE(posts.published_at, posts.created_at) DESC"))
      else
        scope.order(published_at: :desc, created_at: :desc)
      end
    end
end
