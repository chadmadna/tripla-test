class ClockOut
  include Interactor

  def call
    begin
      schedules = context.user.schedules
      last_schedule = schedules.order(created_at: :desc).first
      if schedules.empty?
        context.fail!(message: "User hasn't clocked in yet")
      elsif last_schedule.clock_out.present?
        context.fail!(message: "User already clocked out, need to clock in first")
      end
      ActiveRecord::Base.transaction do
        last_schedule.with_lock do
          last_schedule.update!(clock_out: Time.now)
        end
        context.schedule = last_schedule
      end
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(message: e.message)
    end
  end
end
