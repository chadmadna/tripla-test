class UserSerializer < ActiveModel::Serializer
  type :data
  attributes :id, :name, :email
end
