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

* Database creation

1. En ce qui concerne l'environnement de développement :

Mettre à jour le fichier config/database.yml (il faut "personnaliser" le nom de la database, - ainsi qu'éventuellement le username et le host -, pour le development).

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails db:create

ln-eventbrite-minimum$ RUBYOPT='-W:no-deprecated -W:no-experimental' rails db:migrate

2. En ce qui concerne l'environnement de production :

ln-eventbrite-minimum$ heroku run rails db:migrate

* Deployment instructions

ln-eventbrite-minimum$ heroku ps:scale web=1

* Database initialization

ln-eventbrite-minimum$ heroku run rails db:seed

* How to run the test suite

ln-eventbrite-minimum$ heroku open

ln-eventbrite-minimum$ heroku run rails console

... :001 > ln = User.create(name: "LN", email: "ln@yopmail.com")

* Services (job queues, cache servers, search engines, etc.)

http://www.yopmail.com/

https://app.sendgrid.com/email_activity
