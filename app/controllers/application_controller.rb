class ApplicationController < ActionController::API
  include Pundit::Authorization
  include RackSessionFix

  respond_to :json
  before_action :authenticate_user!

  private

  def authenticate_user!
    if user_signed_in?
      super
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def render_jsonapi_response(resource)
    if resource.errors.empty?
      render json: resource, status: :ok
    else
      render json: { errors: resource.errors }, status: 400
    end
  end
end
