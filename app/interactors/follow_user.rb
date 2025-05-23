class FollowUser
  include Interactor

  def call
    context.attempts ||= 0
    begin
      following = context.current_user.following
      if context.user.id == context.current_user.id
        context.fail! message: "You can't follow yourself"
      elsif following.include?(context.user)
        context.fail! message: "User '#{context.user.name}' already followed"
      else
        following << context.user
        context.message = "User '#{context.user.name}' followed"
      end
    rescue ActiveRecord::StaleObjectError
      context.attempts += 1
      if context.attempts < 3
        sleep 0.1 * context.attempts
        retry
      else
        context.fail!(message: "Something went wrong, please try again")
      end
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(message: e.message)
    end
  end
end
