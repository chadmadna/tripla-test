class Api::SchedulesController < ApplicationController
  def index
    @schedules = policy_scope(Schedule.all)
    authorize @schedules

    # Manual pagination since using raw query
    page_size =  schedule_params[:page_size]&.to_i || 10
    page = schedule_params[:page]&.to_i || 1
    offset = (page - 1) * page_size

    result = GetSleepSchedules.call(user: current_user, limit: page_size, offset: offset)
    if result.success?
      render json: {
        data: result.sleep_schedules,
        pagination: { total: result.total_count, page: page, page_size: page_size },
      }
    else
      render json: { error: result.message }, status: :internal_server_error
    end
  end

  def clock_in
    authorize Schedule
    result = ClockIn.call(user: current_user)
    if result.success?
      render json: result.schedule
    else
      render json: { error: result.message }, status: :internal_server_error
    end
  end

  def clock_out
    authorize Schedule
    result = ClockOut.call(user: current_user)
    if result.success?
      render json: result.schedule
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
