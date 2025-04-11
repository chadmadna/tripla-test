class Api::UsersController < ApplicationController
  before_action :set_user_by_username, only: [:show, :follow, :unfollow]

  def index
    @users = policy_scope(User.all).where.not(id: [current_user.id, current_user.following.pluck(:id)])
    @users = @users.page(user_params[:page]).per(user_params[:per_page])
    authorize @users
    render json: @users, root: 'data'
  end

  def show
    authorize @user
    render json: @user, serializer: UserDetailsSerializer
  end

  def following
    render json: current_user.following
  end

  def followers
    render json: current_user.followers
  end

  def follow
    authorize @user
    result = FollowUser.call(user: @user, current_user: current_user)
    if result.success?
      render json: { message: result.message, following: current_user.reload.following }, status: :ok
    else
      render json: { error: result.message }, status: :unprocessable_entity
    end
  end

  def unfollow
    authorize @user
    result = UnfollowUser.call(user: @user, current_user: current_user)
    if result.success?
      render json: { message: result.message, following: current_user.reload.following }, status: :ok
    else
      render json: { error: result.message }, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_username
    begin
      @user = User.find(user_params[:id])
    rescue ActiveRecord::RecordNotFound, Pundit::NotAuthorizedError, Pundit::NotDefinedError => e
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def user_params
    params.permit(
      :utf_8,
      :authenticity_token,
      :commit,
      :page,
      :per_page,
      :id
    )
  end
end
