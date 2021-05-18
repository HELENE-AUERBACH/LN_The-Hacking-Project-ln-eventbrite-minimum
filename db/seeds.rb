# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'
require 'bcrypt'

ActiveRecord::Base.connection.tables.each do |table|
  if table != "ar_internal_metadata" && table != "schema_migrations"
    puts "Resetting auto increment ID for #{table} to 1"
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH 1")
  end
end
Attendance.destroy_all
Event.destroy_all
User.destroy_all

users_array = []
events_array = []
attendances_array = []

Faker::Config.locale = 'fr'

puts "\nCréation d'un utilisateur de prénom, de nom et de password \"Anonymous\", qui a pour email \"anonymous@yopmail.com\"."
anonymous_user = User.create(first_name: "Anonymous",
                             last_name: "Anonymous",
                             description: "Utilisateur créé afin qu'il soit l'administrateur de plusieurs événements, ainsi que le participant.",
                             email: "anonymous@yopmail.com",
                             encrypted_password: BCrypt::Password.create("Anonymous")
                            )
users_array << anonymous_user

start_date = Faker::Date.between(from: 3.days.from_now, to: 5.months.from_now)

event1 = Event.new(start_date: start_date,
                   duration: 2 * 60,
                   title: "Evénement n°1",
                   description: "Evénement administré par \"Anonymous Anonymous\" qui en est aussi l'un des participants.",
                   price: 1,
                   location: "Paris"
                  )
events_array << event1
event1.admin = anonymous_user
event1.save

attendance1 = Attendance.new(stripe_customer_id: Faker::Number.between(from: 1, to: 95).to_s + Faker::Number.between(from: 100, to: 999).to_s)
attendances_array << attendance1
attendance1.attending = anonymous_user
attendance1.event = event1
attendance1.save

puts "\nGénération plus aléatoire :"

n = 3

n.times do |index|
  first_name = Faker::Name.unique.first_name
  last_name = Faker::Name.unique.last_name
  email = "#{first_name.gsub(' ', '').downcase}_#{last_name.gsub(' ', '').downcase}@yopmail.com"
  password = Faker::Internet.password(min_length: 6, max_length: 10)
  puts "\nLe password du #{index + 2}-ième utilisateur - de prénom \"#{first_name.capitalize}\", de nom \"#{last_name.capitalize}\" et d'email \"#{email}\" - créé par ce seed sera : \"#{password}\"."
  user = User.create(first_name: "#{first_name.capitalize}",
                     last_name: "#{last_name.capitalize}",
                     description: ("#{first_name.capitalize} #{last_name.capitalize} est une #{index + 2}-ième personne (de password \"#{password}\") : " + Faker::Lorem.characters(number: 15)),
                     email: "#{email}",
                     encrypted_password: BCrypt::Password.create(password)
                    )
  users_array << user

  event = Event.new(start_date: start_date + (1 + index).days,
                    duration: 2 * (3 + index) * 60,
                    title: "Evénement n°#{index + 2}",
                    description: "Evénement administré par \"#{users_array[index].first_name} #{users_array[index].last_name}\".",
                    price: Faker::Number.between(from: 1, to: 1000),
                    location: Faker::Address.unique.city
                   )
  events_array << event
  event.admin = users_array[index]
  event.save
  
  if index < 2
    attendance = Attendance.new(stripe_customer_id: Faker::Number.between(from: 1, to: 95).to_s + Faker::Number.between(from: 100, to: 999).to_s)
    attendances_array << attendance
    attendance.attending = user
    attendance.event = event
    attendance.save
  end
  
  if index == 1
    attendance = Attendance.new(stripe_customer_id: Faker::Number.between(from: 1, to: 95).to_s + Faker::Number.between(from: 100, to: 999).to_s)
    attendances_array << attendance
    attendance.attending = users_array[0]
    attendance.event = event
    attendance.save
    attendance = Attendance.new(stripe_customer_id: Faker::Number.between(from: 1, to: 95).to_s + Faker::Number.between(from: 100, to: 999).to_s)
    attendances_array << attendance
    attendance.attending = users_array[1]
    attendance.event = event
    attendance.save
  end
end

require 'table_print'

tp.set User, :id, :first_name, :last_name, :email, :encrypted_password, :description
#tp.set Event, :id,
#              {start_date: {:width => 10, :time_format => '%Y-%m-%d'}},
#              {duration: {:width => 8}},
#              {"admin.id": {:width => 8, :display_name => "Admin Id"}},
#              {"admin.email": {:width => 25, :display_name => "Admin Email"}},
#              {"attendings.id": {:width => 8, :display_name => "Attg. Id"}},
#              {"attendings.first_name": {:width => 20, :display_name => "Attending Firstname"}},
#              {"attendings.last_name": {:width => 20, :display_name => "Attending Lastname"}},
#              {"attendings.email": {:width => 52, :display_name => "Attending Email"}},
#              {"attendances.id": {:width => 8, :display_name => "Attc. Id"}},
#              {"attendances.stripe_customer_id": {:width => 18, :display_name => "Stripe Customer Id"}},
#              {price: {:width => 5}},
#              {location: {:width => 20}},
#              {title: {:width => 13}},
#              {description: {:width => 70}}

puts "#{users_array.length} users créés :\n"
tp User.all

tp.set Event, :id,
              {start_date: {:width => 10, :time_format => '%Y-%m-%d'}},
              {duration: {:width => 8}},
              {"admin.id": {:width => 8, :display_name => "Admin Id"}},
              {"admin.email": {:width => 25, :display_name => "Admin Email"}},
              {price: {:width => 5}},
              {location: {:width => 20}},
              {title: {:width => 13}},
              {description: {:width => 70}}

puts "\n#{events_array.length} events créés :\n"
tp Event.all

tp.set Event, :id,
              {"attendings.id": {:width => 12, :display_name => "Attending Id"}},
              {"attendings.first_name": {:width => 20, :display_name => "Attending Firstname"}},
              {"attendings.last_name": {:width => 20, :display_name => "Attending Lastname"}},
              {"attendings.email": {:width => 52, :display_name => "Attending Email"}},
              {"attendances.id": {:width => 13, :display_name => "Attendance Id"}},
              {"attendances.stripe_customer_id": {:width => 18, :display_name => "Stripe Customer Id"}}

puts "\n#{attendances_array.length} attendances créés pour #{events_array.length} events créés :\n"
tp Event.all
