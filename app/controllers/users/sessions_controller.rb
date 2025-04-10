class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    token = request.env['warden-jwt_auth.token']
    render json: {
      status: 200,
      message: 'Logged in successfully.',
      data: {
        user: {
          id: resource.id,
          email: resource.email,
          roles: resource.roles.map(&:name),
          token: token
        }
      }
    }
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }
    else
      render json: {
        status: 401,
        message: "Couldn't log out from existing session."
      }
    end
  end
end
