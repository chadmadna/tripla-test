FactoryBot.define do
  factory :role do
    permissions { [association(:permission)] }

    trait :regular do
      name { :regular }
    end

    trait :admin do
      name { :admin }
    end
  end

  factory :permission do
    name { :default }
  end
end
