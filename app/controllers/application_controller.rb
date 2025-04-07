class ApplicationController < ActionController::API
  include Pundit::Authorization

  respond_to :json
  before_action :authenticate_user!

  private

  def render_jsonapi_response(resource)
    if resource.errors.empty?
      render json: resource, status: :ok
    else
      render json: { errors: resource.errors }, status: 400
    end
  end
end
