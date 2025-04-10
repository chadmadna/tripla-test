class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def initialize(user, record)
      @user = user
      @record = record
      @action = action
    end

    def resolve
      if user.has_role?(:admin, User)
        User.all
      elsif !record.is_admin?
        record
      else
        User.none
      end
    end

    private

    attr_reader :user, :record, :action
  end

  def index?
    user.has_role?(:admin, User) or (user.has_role?(:regular) and !resource.is_admin?)
  end

  def show?
    user.has_role?(:admin, User) or (user.has_role?(:regular) and !resource.is_admin?)
  end

  def follow?
    user.has_role?(:admin, User) or user.has_role?(:regular)
  end

  def unfollow?
    user.has_role?(:admin, User) or user.has_role?(:regular)
  end
end
