class ClockIn
  include Interactor

  def call
    begin
      schedules = context.user.schedules
      last_schedule = schedules.order(created_at: :desc).first
      if schedules.present? and !last_schedule.clock_out.present?
        context.fail!(message: "User hasn't clocked out yet")
      end
      ActiveRecord::Base.transaction do
        if schedules.empty? or last_schedule.clock_out.present?
          schedule = schedules.lock.create!(user: context.user, clock_in: Time.now)
          context.schedule = schedule
        else
          last_schedule.with_lock do
            last_schedule.update!(clock_in: Time.now)
          end
          context.schedule = last_schedule
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(message: e.message)
    end
  end
end
