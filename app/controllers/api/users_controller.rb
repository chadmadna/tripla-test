class Api::UsersController < ApplicationController
  before_action :set_user_by_username, only: [:show, :follow, :unfollow]

  def index
    @users = policy_scope(User.all).where.not(id: current_user.id)
    authorize @users
    render json: @users
  end

  def show
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
      @user = User.find_by(email: "#{params[:username]}@triplatest.com")
      authorize @user
    rescue ActiveRecord::RecordNotFound, Pundit::NotAuthorizedError, Pundit::NotDefinedError
      render json: { error: "User not found" }, status: :not_found
    end
  end
end
