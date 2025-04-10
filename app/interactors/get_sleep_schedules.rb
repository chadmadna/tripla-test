class GetSleepSchedules
  include Interactor

  def call
    context.attempts ||= 0
    begin
      user_ids = ActiveRecord::Base.sanitize([context.user.following.pluck(:id), context.user.id].flatten)
      sql = <<~SQL
        WITH numbered AS (
          SELECT *,
                ROW_NUMBER() OVER (ORDER BY clock_in) AS rn
          FROM schedules
          WHERE user_id IN (#{user_ids.join(',')})
        ),
        paired AS (
          SELECT
            s1.id AS from_id,
            s1.clock_out,
            s2.clock_in,
            s2.id AS to_id,
            s1.user_id AS user_id,
            CASE
              WHEN s2.clock_in < s1.clock_out THEN
                (TIME '00:00' + s2.clock_in) + INTERVAL '1 day' - (TIME '00:00' + s1.clock_out)
              ELSE
                (TIME '00:00' + s2.clock_in) - (TIME '00:00' + s1.clock_out)
            END AS gap
          FROM numbered s1
          JOIN numbered s2 ON s2.rn = s1.rn + 1
        )
        SELECT * FROM paired
        ORDER BY gap DESC
      SQL

      limit = ActiveRecord::Base.sanitize(context.limit)
      offset = ActiveRecord::Base.sanitize(context.offset)
      paginated_sql = <<~SQL
        #{sql}
        LIMIT #{limit}
        OFFSET #{offset}
      SQL

      raw_results = ActiveRecord::Base.connection.execute(paginated_sql)
      context.sleep_schedules = raw_results.map do |result|
        {
          user_id: result['user_id'],
          clock_out: result['clock_out'],
          clock_in: result['clock_in']
          duration: result['gap'],
        }
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
