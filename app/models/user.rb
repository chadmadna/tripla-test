class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :publisher
  has_many :permissions, through: :roles

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :invitable

  validates_presence_of :publisher
  before_validation :assign_role_to_account_owner

  private

  def assign_role_to_account_owner
    admin_role = Role.find_or_create_by(name: "admin", resource: publisher) do |role|
      role.permissions = Permission.all
    end

    add_role(:admin, publisher) if admin_role.persisted? && !invited_by.present?
  end
end
