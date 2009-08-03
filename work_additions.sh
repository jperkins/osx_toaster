#!/usr/bin/env bash


# add test for and bail with error msg if prerequisites aren't met
#
# prerequisites:
#   - access to the centro git repo
#   - access to samba



# ---------------------------------------------------------------------------
# create pg databases and users
# ---------------------------------------------------------------------------

# add users to pg
sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s mms'
sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s jperkins'

sleep 1

# create the databases we'll need locally
/opt/local/lib/postgresql84/bin/createdb mms_development
/opt/local/lib/postgresql84/bin/createdb mms_test


# ---------------------------------------------------------------------------
# checkout a copy of transis
# ---------------------------------------------------------------------------

# mkdir -p ~/Centro
# cd ~/Centro
# git clone


# ---------------------------------------------------------------------------
# gem installation
# ---------------------------------------------------------------------------

# rake gems:install including the dev and test environments
# individually until we can hammer out rake gems:install

sudo gem install pg
sudo gem install newrelic_rpm
sudo gem install fastercsv
sudo gem install hpricot
sudo gem install mktemp
sudo gem install paperclip -v "2.1.2"
sudo gem install rake -v ">=0.8.2"
sudo gem install rubyzip
sudo gem install stomp
sudo gem install tamtam
sudo gem install thoughtbot-shoulda
sudo gem install uuidtools
sudo gem install ruby-ole
sudo gem install spreadsheet -v "0.6.4"
sudo gem install thumblemonks-sso_what
sudo gem install chronic
sudo gem install javan-whenever
sudo gem install gabrielg-factory_girl
sudo gem install mocha -v "0.9.5"
sudo gem install ruby-debug
sudo gem install vlad


# ---------------------------------------------------------------------------
# populate the database, run any pending migrations and then rake test
# ---------------------------------------------------------------------------

cd ~/Centro/transis

rake db:clone_production
rake db:migrate
rake test




