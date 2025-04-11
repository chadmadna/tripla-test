require 'dotiw'

class ScheduleSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attributes :clock_in, :clock_out, :duration

  def duration
    if object.clock_in.present? && object.clock_out.present?
      distance_of_time_in_words(object.clock_out - object.clock_in)
    else
      distance_of_time_in_words(Time.now - object.clock_in)
    end
  end
end
