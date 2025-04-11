class User < ApplicationRecord
  include Discard::Model

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :publisher
  has_many :permissions, through: :roles

  has_many :user_follows, foreign_key: :following_id

  has_many :following_relationships, class_name: "UserFollow", foreign_key: :follower_id
  has_many :follower_relationships, class_name: "UserFollow", foreign_key: :following_id

  has_many :following, through: :following_relationships, source: :following
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :schedules
end
