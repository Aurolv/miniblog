class PostsController < ApplicationController
  before_action :require_login, only: [ :new, :create, :edit, :update, :destroy, :drafts, :publish, :unpublish ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :publish, :unpublish ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy, :publish, :unpublish ]

  # GET /posts or /posts.json
  def index
    @posts = Post.published.order(published_at: :desc).page(params[:page]).per(10)
  end

  def drafts
    @posts = current_user.posts.draft.order(updated_at: :desc).page(params[:page]).per(10)
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
    def set_post = @post = Post.find(params[:id])

    def authorize_owner!; head :forbidden unless @post.user_id == current_user.id; end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :status)
    end

    def post_params_with_publish_time
      attrs = post_params.to_h
      attrs["status"] == "published"? attrs["published_at"] ||= Time.current : attrs["published_at"] = nil

      attrs
    end
end
