class SchedulePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.has_role?(:admin)
        scope.all
      elsif @user.has_role?(:regular)
        scope.where(user: @user).or(scope.where(user: @user.following))
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

  def clock_in?
    true
  end

  def clock_out?
    true
  end
end
