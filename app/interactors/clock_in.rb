class ClockIn
  include Interactor

  def call
    begin
      schedules = context.user.schedules
      last_schedule = schedules.order(created_at: :desc).first
      if schedules.present? and last_schedule.clock_out.empty?
        context.fail!(message: "User hasn't clocked out yet")
      end
      ActiveRecord::Base.transaction do
        if schedules.empty?
          schedules.with_lock do
            schedule << Schedule.create!(user: context.user, clock_in: Time.now)
            context.schedule = schedule
          end
        else
          last_schedule.with_lock do
            last_schedule.update!(clock_in: Time.now)
            context.schedule = last_schedule
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(message: e.message)
    end
  end
end
