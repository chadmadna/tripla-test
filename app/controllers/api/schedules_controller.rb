class Api::SchedulesController < ApplicationController
  def index
    @schedules = policy_scope(Schedule.all)
    authorize @schedules

    # Manual pagination since using raw query
    page_size =  schedule_params[:page_size] || 10
    page = schedule_params[:page] || 1
    limit = page_size.to_i
    offset = (page.to_i - 1) * limit

    result = GetSleepSchedules.call(user: current_user, limit: limit, offset: offset)
    if result.success?
      render json: result.sleep_schedules
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
