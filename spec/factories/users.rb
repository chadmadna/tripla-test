FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    created_at { Faker::Time.between(from: 2.days.ago, to: 1.day.ago) }
    updated_at { Faker::Time.between(from: 1.day.ago, to: Time.current) }

    after(:build) do |user|
      user.publisher = Publisher.first || create(:publisher)
      user.roles << Role.find_or_create_by(name: 'regular')
      user.invited_by ||= User.find_by(email: 'admin@example.com')
    end

    trait :admin do
      after(:build) do |user|
        user.publisher = Publisher.first || create(:publisher)
        user.email = 'admin@example.com'
        user.roles = [Role.find_or_create_by(name: 'admin')]
        user.invited_by = nil
      end
    end
  end

  factory :publisher do
    name { Faker::Lorem.sentence }
  end
end
