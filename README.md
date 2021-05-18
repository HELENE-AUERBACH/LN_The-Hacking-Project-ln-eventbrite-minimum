# README

This README would normally document whatever steps are necessary to get the
application up and running.

* Ruby version

ruby 2.7.1p83 (2020-03-31 revision a0c7c23c9c) [x86_64-linux]

* Rails version

Rails 5.2.3

* Configuration

rm ln-eventbrite-minimum/Gemfile.lock

$ gem uninstall rails
(=> 3. All versions)

$ gem uninstall railties
(=> 3. All versions => y, then Y)

$ cd ln-eventbrite-minimum

ln-eventbrite-minimum$ bundle install

ln-eventbrite-minimum$ rails -v
(=> Rails 5.2.3)

1. En ce qui concerne l'environnement de développement :

* Database creation

Mettre à jour le fichier config/database.yml (il faut "personnaliser" le nom de la database, - ainsi qu'éventuellement le username et le host -, pour le development).

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails db:create

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails db:migrate

* Database initialization

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails db:seed

* How to run the test suite

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails console

... :001 > require 'bcrypt'
... :002 > ln = User.create(first_name: "LN", last_name: "Anonymous", description: "LN Anonymous/ln@yopmail.com - Tototo", email: "ln@yopmail.com", encrypted_password: BCrypt::Password.create("Tototo"))

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails server (=> http://localhost:3000 )

2. En ce qui concerne l'environnement de production :

ln-eventbrite-minimum$ heroku run rails db:migrate

* Deployment instructions

ln-eventbrite-minimum$ heroku ps:scale web=1

* Database initialization

ln-eventbrite-minimum$ heroku run rails db:seed

* How to run the test suite

ln-eventbrite-minimum$ heroku open (=> https://ln-thp-ln-eventbrite-minimum.herokuapp.com )

ln-eventbrite-minimum$ heroku run rails console

... :001 > require 'bcrypt'
... :002 > ln = User.create(first_name: "LN", last_name: "Anonymous", description: "LN Anonymous/ln@yopmail.com - Tototo", email: "ln@yopmail.com", encrypted_password: BCrypt::Password.create("Tototo"))

* Services (job queues, cache servers, search engines, etc.)

http://www.yopmail.com/

https://app.sendgrid.com/email_activity
