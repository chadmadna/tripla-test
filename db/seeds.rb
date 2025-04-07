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
User.destroy_all
Publisher.destroy_all
Role.destroy_all
Permission.destroy_all

puts "Creating permissions..."
admin_permissions = [
  'Users#view_list',
  'Users#view_one',
  'Users#view_admin_list',
  'Users#view_admin_one',
  'Follows#follow',
  'Follows#unfollow',
  'Follows#follow_admin',
  'Follows#unfollow_admin',
  'Schedules#view_list',
  'Schedules#view_one',
  'Schedules#clock_in',
  'Schedules#clock_out',
  'Schedules#view_sleep_schedules',
  'Publishers#view_list',
  'Publishers#view_one',
].map do |permission_name|
  Permission.create!(name: permission_name)
end

user_permissions = [
  "Users#view_list",
  "Users#view_one",
  "Follows#follow",
  "Follows#unfollow",
  "Schedules#view_list",
  "Schedules#view_one",
  "Schedules#clock_in",
  "Schedules#clock_out",
  "Schedules#view_sleep_schedules",
]

puts "User permissions: #{user_permissions}"

puts "Creating publisher..."
publisher = Publisher.create!(
  name: "Main Publisher"
)

puts "Creating roles..."
admin_role = Role.create!(
  name: 'admin',
  resource: publisher,
  permissions: Permission.all
)

regular_role = Role.create!(
  name: 'regular',
  resource: publisher,
  permissions: Permission.where(name: user_permissions)
)

puts "Creating admin user..."
admin_user = User.create!(
  email: 'admin@triplatest.com',
  password: 'admin@tripla!',
  password_confirmation: 'admin@tripla!',
  name: 'Admin User',
  publisher: publisher
)
admin_user.save!
admin_user.add_role(:admin, publisher)

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
  user.save!
  user.add_role(:regular, publisher)

  puts "Created regular user #{i + 1}: #{user.email}"
end

puts "\nSeeding completed!"
puts "Admin credentials:"
puts "Email: admin@example.com"
puts "Password: admin@tripla!"
puts "\nStats:"
puts "Total users created: #{User.count}"
puts "Users with admin role: #{User.with_role(:admin, publisher).count}"
puts "Users with regular role: #{User.with_role(:regular, publisher).count}"
