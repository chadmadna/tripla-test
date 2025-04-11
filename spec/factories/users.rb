FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    roles { [Role.find_by(name: 'regular')] }
    publisher { Publisher.first || create(:publisher) }
    invited_by { User.includes(:roles).find_by(roles: { name: 'admin' }) }
    created_at { Faker::Time.between(from: 2.days.ago, to: 1.day.ago) }
    updated_at { Faker::Time.between(from: 1.day.ago, to: Time.current) }

    trait :regular do
      User.includes(:roles).find_by(roles: { name: 'admin' })
      roles { [Role.find_by(name: 'regular')] }
    end

    trait :admin do
      invited_by { nil }
      roles { [Role.find_by(name: 'admin')] }
    end
  end

  factory :publisher do
    name { Faker::Lorem.sentence }
  end
end
