# Fix for Devise sessions if you don't use sessions
# https://sdrmike.medium.com/rails-7-api-only-app-with-devise-and-jwt-for-authentication-1397211fb97c
module RackSessionsFix
  extend ActiveSupport::Concern
  class FakeRackSession < Hash
    def enabled?
      false
    end
    def destroy; end
  end
  included do
    before_action :set_fake_session
    private
    def set_fake_session
      request.env['rack.session'] ||= FakeRackSession.new
    end
  end
end
