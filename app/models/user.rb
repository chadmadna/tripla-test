class User < ApplicationRecord
  include Discard::Model

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :publisher
  has_many :permissions, through: :roles

  validates_presence_of :publisher
  before_validation :assign_role_to_account_owner

  has_many :user_follows, foreign_key: :following_id

  has_many :followers, through: :user_follows, source: :follower
  has_many :following, through: :user_follows, source: :following

  private

  def assign_role_to_account_owner
    admin_role = Role.find_or_create_by(name: "admin", resource: publisher) do |role|
      role.permissions = Permission.all
    end

    add_role(:admin, publisher) if admin_role.persisted? && !invited_by.present?
  end
end
