class UserDetailsSerializer < ActiveModel::Serializer
  type :data
  attributes :id, :name, :email

  has_many :followers, each_serializer: UserSerializer
  has_many :following, each_serializer: UserSerializer

  has_many :schedules, each_serializer: ScheduleSerializer
end
