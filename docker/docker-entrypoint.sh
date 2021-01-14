#!/bin/bash

source /root/.nvm/nvm.sh 

timestamp="date +\"%Y-%m-%d %H:%M:%S\""
alias echo="echo \"$(eval $timestamp) -$@\""

# Get current state of database.
db_version=$(rake db:version)
db_status=$?

echo "DB Version: ${db_version}"

# Provision Database.
if [ "$db_status" != "0" ]; then
  echo "Creating database."
  rake db:create
  echo "Loading schema."
  rake db:schema:load
  echo "Migrating database."
  rake db:migrate
  echo "Seeding database."
  rake db:seed
elif [ "$db_version" = "Current version: 0" ]; then
  echo "Loading schema."
  rails db:schema:load
  echo "Migrating database."
  rails db:migrate
  echo "Seeding database."
  rails db:seed
else
  echo "Migrating database."
  rake db:migrate
fi

# Set out SECRET_KEY
if [ "$SECRET_KEY" = "" ]; then
  echo "No SECRET_KEY provided, generating one now."
  export SECRET_KEY=$(bundle exec rake secret)
  echo "Your new secret key: $SECRET_KEY"
fi

# Compile our assets.
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rake assets:precompile
fi

# Start the rails application.
bundle exec rails server -b 0.0.0.0 &
pid="$!"
trap "echo 'Stopping Lobsters - pid: $pid'; kill -SIGTERM $pid" SIGINT SIGTERM

# Run the cron job every 5 minutes
while : ; do
  echo "Running cron jobs."
  bundle exec ruby script/mail_new_activity.rb
  bundle exec ruby script/post_to_twitter
  sleep 300
done &

# Wait for process to end.
while kill -0 $pid > /dev/null 2>&1; do
    wait
done
echo "Exiting"
