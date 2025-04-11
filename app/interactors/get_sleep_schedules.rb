require 'dotiw'

class GetSleepSchedules
  include Interactor
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  def call
    context.attempts ||= 0
    begin
      user_ids = context.user.following.pluck(:id)
      sql = <<~SQL
        WITH numbered AS (
          SELECT *,
                ROW_NUMBER() OVER (ORDER BY clock_in) AS rn
          FROM schedules
          WHERE user_id IN (?)
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
        ),
        total_count AS (
          SELECT COUNT(*) AS count FROM paired
        )
        SELECT user_id, clock_out, clock_in, gap::interval AS gap,
               (SELECT count FROM total_count) AS total_count
        FROM paired
        ORDER BY gap DESC
        LIMIT ? OFFSET ?
      SQL

      sanitized_sql = ActiveRecord::Base.sanitize_sql([sql, user_ids, context.limit, context.offset])

      raw_results = ActiveRecord::Base.connection.execute(sanitized_sql)
      context.sleep_schedules = raw_results.map do |result|
        Struct.new('SleepSchedule', :user_id, :clock_out, :clock_in, :duration).new(
          result['user_id'],
          result['clock_out'],
          result['clock_in'],
          distance_of_time_in_words(
            ActiveSupport::Duration.parse(result['gap']),
          )
        )
      end
      context.total_count = raw_results.first.try(:[], 'total_count') || 0
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
