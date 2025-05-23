class Api::SchedulesController < ApplicationController
  def index
    @schedules = policy_scope(Schedule.all)
    authorize @schedules

    # Manual pagination since using raw query
    per_page =  schedule_params[:per_page]&.to_i || 10
    page = schedule_params[:page]&.to_i || 1
    offset = (page - 1) * per_page

    result = GetSleepSchedules.call(user: current_user, limit: per_page, offset: offset)
    if result.success?
      render json: {
        data: result.sleep_schedules,
        pagination: { page: page, per_page: per_page, total: result.total_count },
      }
    else
      render json: { error: result.message }, status: :internal_server_error
    end
  end

  def clock_in
    authorize Schedule
    result = ClockIn.call(user: current_user)
    if result.success?
      render json: { message: "Good morning, #{current_user.name}! Enjoy your day.",  time: result.schedule.clock_in }
    else
      render json: { error: result.message }, status: :internal_server_error
    end
  end

  def clock_out
    authorize Schedule
    result = ClockOut.call(user: current_user)
    if result.success?
      render json: { message: "Good night, #{current_user.name}. Have a good rest.",  time: result.schedule.clock_out }
    else
      render json: { error: result.message }, status: :internal_server_error
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def schedule_params
    params.permit(
      :utf_8,
      :authenticity_token,
      :commit,
      :page,
      :per_page
    )
  end
end
