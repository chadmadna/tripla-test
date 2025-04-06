class Publisher < ApplicationRecord
  has_many :users

  # for accessing User attrs and validations
  accepts_nested_attributes_for :users

  validates :name, presence: true, uniqueness: true, length: { minimum: 2 }
  validates :description, presence: true, if: -> { description.present? }

  resourcify
end
