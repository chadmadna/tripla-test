# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb
require 'faker'

# Clean database
UserFollow.destroy_all
User.destroy_all
Publisher.destroy_all
Role.destroy_all
Permission.destroy_all

Permission.create!(
  name: 'default',
)

puts "Creating publisher..."
publisher = Publisher.create!(
  name: "Main Publisher"
)

puts "Creating roles..."
admin_role = Role.create!(
  name: 'admin',
  permissions: Permission.all
)

regular_role = Role.create!(
  name: 'regular',
  permissions: Permission.all
)

puts "Creating admin user..."
admin_user = User.create!(
  email: 'admin@triplatest.com',
  password: 'admin@tripla!',
  password_confirmation: 'admin@tripla!',
  name: 'Admin User',
  publisher: publisher
)
admin_user.add_role(:admin)
admin_user.save!

puts "Creating regular users..."
10.times do |i|
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  user = User.new(
    email: "user_#{i + 1}@triplatest.com",
    password: 'user@tripla!',
    password_confirmation: 'user@tripla!',
    name: "User #{i + 1}",
    invited_by: admin_user, # This prevents automatic admin role assignment
    publisher: publisher
  )
  user.add_role(:regular)
  user.save!

  puts "Created regular user #{i + 1}: #{user.email}"
end

regular_users = User.includes(:roles).where({ roles: { name: :regular } })
regular_users.each do |user|
  users_to_follow = regular_users.where.not(id: user.id).filter { |u| user.id % 2 == 0 ? u.id % 2 == 0 : u.id % 2 == 1 }
  users_to_follow.each do |following|
    UserFollow.create!(follower: user, following: following)
  end
  puts "User #{user.email} following #{users_to_follow.map(&:email).join(', ')}"
end

# Create Clock-In/Clock-Out Schedules
regular_users.each do |user|
  last_clock_out_time = DateTime.new(2025, 1, 1)
  30.times do
    clock_in_time = Faker::Time.between(from: last_clock_out_time, to: last_clock_out_time + 3.days)
    clock_out_time = Faker::Time.between(from: clock_in_time, to: clock_in_time + 8.hours)
    if clock_in_time > DateTime.new(2025, 4, 10) || clock_out_time > DateTime.new(2025, 4, 10)
      break
    end

    user.schedules.create!(clock_in: clock_in_time, clock_out: clock_out_time)
    last_clock_out_time = clock_out_time
  end
  puts "Created clock-in/out schedules for #{user.email}"
end

puts "\nSeeding completed!"
puts "Admin credentials:"
puts "Email: admin@example.com"
puts "Password: admin@tripla!"
puts "\nStats:"
puts "Total users created: #{User.count}"
puts "Users with admin role: #{User.with_role(:admin).count}"
puts "Users with regular role: #{User.with_role(:regular, publisher).count}"
