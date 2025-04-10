class Api::UsersController < ApplicationController
  before_action :set_user_by_username, only: [:show, :following, :followers, :follow, :unfollow]

  def index
    @users = User.all
    authorize @users
    return render_jsonapi_response(@users)
  end

  def show
    return render_jsonapi_response(@user)
  end

  def following
    return render_jsonapi_response(@user.following)
  end

  def followers
    return render_jsonapi_response(@user.followers)
  end

  def follow
    authorize @user
    current_user.following << @user
    return render_jsonapi_response(@user.following)
  end

  def unfollow
    authorize @user
    @user.following.delete(@user)
    return render_jsonapi_response(@user.following)
  end
  private

  def set_user_by_username
    begin
      @user = User.find_by(email: "#{params[:username]}@triplatest.com")
      authorize @user
    rescue ActiveRecord::RecordNotFound, Pundit::NotAuthorizedError
      render_jsonapi_response({ error: "User not found" }, :not_found)
    end
  end
end
