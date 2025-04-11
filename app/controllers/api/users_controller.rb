class Api::UsersController < ApplicationController
  before_action :set_user_by_username, only: [:show, :follow, :unfollow]

  def index
    @users_all = policy_scope(User.all).where.not(id: [current_user.id, current_user.following.pluck(:id)])
    page = user_params[:page].try(:to_i) || 1
    per_page = user_params[:per_page].try(:to_i) || 10
    @users = @users_all.page(page).per(per_page)
    authorize @users
    render json: {
      data: { users: @users.to_json(only: [:id, :email, :name]) },
      pagination: { page: page, per_page: per_page, total: @users_all.size }
    }
  end

  def show
    authorize @user
    render json: @user, serializer: UserDetailsSerializer
  end

  def following
    @following_all = current_user.following
    page = user_params[:page].try(:to_i) || 1
    per_page = user_params[:per_page].try(:to_i) || 10
    @following = @following_all.page(page).per(per_page)
    render json: {
      data: { users: @following },
      pagination: { page: page, per_page: per_page, total: @following_all.size }
    }
  end

  def followers
    @followers_all = current_user.followers
    page = user_params[:page].try(:to_i) || 1
    per_page = user_params[:per_page].try(:to_i) || 10
    @followers = @followers_all.page(page).per(per_page)
    render json: {
      data: { users: @followers },
      pagination: { page: page, per_page: per_page, total: @followers_all.size }
    }
  end

  def follow
    authorize @user
    result = FollowUser.call(user: @user, current_user: current_user)
    if result.success?
      render json: { message: result.message, following: current_user.reload.following.as_json(only: [:id, :email, :name]) }, status: :ok
    else
      render json: { error: result.message }, status: :bad_request
    end
  end

  def unfollow
    authorize @user
    result = UnfollowUser.call(user: @user, current_user: current_user)
    if result.success?
      render json: { message: result.message, following: current_user.reload.following.as_json(only: [:id, :email, :name]) }, status: :ok
    else
      render json: { error: result.message }, status: :bad_request
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
