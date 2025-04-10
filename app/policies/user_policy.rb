class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.has_role?(:admin, User)
        scope.all
      elsif @user.has_role?(:regular)
        scope.includes(:roles).where.not({ roles: { name: :admin } })
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  def index?
    true
  end

  def show?
    user.has_role?(:admin, User) or (user.has_role?(:regular) and !record.is_admin?)
  end

  def follow?
    user.has_role?(:admin, User) or (user.has_role?(:regular) and !record.is_admin?)
  end

  def unfollow?
    user.has_role?(:admin, User) or (user.has_role?(:regular) and !record.is_admin?)
  end
end
