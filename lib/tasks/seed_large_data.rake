namespace :db do
  desc "Seed large amounts of data"
  task seed_large_data: [:environment] do
    require 'faker'

    Schedule.destroy_all
    UserFollow.destroy_all
    User.destroy_all
    Publisher.destroy_all
    Role.destroy_all
    Permission.destroy_all

    Permission.create!(
      name: 'default',
    )

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

    # Create Admin User
    admin_user = User.create!(
      email: 'admin@triplatest.com',
      password: 'admin@tripla!',
      password_confirmation: 'admin@tripla!',
      name: 'Admin User',
      publisher: publisher
    )
    admin_user.add_role(:admin)
    admin_user.save!

    puts "Created Admin User: #{admin_user.email}"

    # Create Regular Users
    users = []
    300.times do |i|
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
      users << user

      puts "Created regular user #{i + 1}: #{user.email}"
    end

    # Set up Follow Relationships
    users = User.where(email: users.map(&:email))
    users.each do |user|
      if user.id.even?
        # Follow 5 even ids below and above
        follow_ids = ((user.id - 10)..(user.id + 10)).select { |id| id.even? && id != user.id }
      else
        # Follow 5 odd ids below and above
        follow_ids = ((user.id - 10)..(user.id + 10)).select { |id| id.odd? && id != user.id }
      end

      follow_ids = follow_ids.select { |id| id > users.order(:id).first.id && id <= users.order(:id).last.id }.first(5)
      follow_ids.each do |follow_id|
        user.following << User.find(follow_id)
      end
      puts "User #{user.email} follows #{follow_ids.size} users"
    end

    # Create Clock-In/Clock-Out Schedules
    users.each do |user|
      last_clock_out_time = DateTime.new(2025, 1, 1)
      (30..100).to_a.sample.times do
        clock_in_time = Faker::Time.between(from: last_clock_out_time, to: last_clock_out_time + 12.hours)
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
  end
end
