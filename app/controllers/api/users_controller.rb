class Api::UsersController < ApplicationController
  before_action :set_user_by_username, only: [:show, :follow, :unfollow]

  def index
    @users = policy_scope(User.all).where.not(id: current_user.id)
    authorize @users
    render json: { data: @users }
  end

  def show
    render json: { data: @user }
  end

  def following
    render json: { data: current_user.following }
  end

  def followers
    render json: { data: current_user.followers }
  end

  def follow
    authorize @user
    if @user.id == current_user.id
      render json: { error: "You can't follow yourself" }, status: :unprocessable_entity
    elsif current_user.following.include?(@user)
      render json: { error: "User '#{@user.name}' already followed" }, status: :unprocessable_entity
    else
      current_user.following << @user
      render json: { message: "User '#{@user.name}' followed" }, status: :ok
    end
  end

  def unfollow
    authorize @user
    if @user.id == current_user.id
      render json: { error: "You can't unfollow yourself" }, status: :unprocessable_entity
    elsif current_user.following.include?(@user)
      current_user.following.delete(@user)
      render json: { message: "User '#{@user.name}' unfollowed" }, status: :ok
    else
      render json: { error: "User '#{@user.name}' not followed" }, status: :unprocessable_entity
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
