class Schedule < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true

  validate :clock_out_after_clock_in

  private

  def clock_out_after_clock_in
    if clock_in.present? && clock_out.present? && clock_out <= clock_in
      errors.add(:clock_out, "must be after clock_in")
    end
  end
end
