#!/usr/bin/env bash

# prerequisites:
# os x developer tools, access to the centro git repo, access to samba


# ---------------------------------------------------------------------------
# install macports
# ---------------------------------------------------------------------------

mkdir -p /opt/mports
cd /opt/mports
/usr/bin/svn checkout http://svn.macports.org/repository/macports/trunk/base
cd ./base/
./configure --enable-readline
make
sudo make install
sudo /opt/local/bin/port -v selfupdate
cd ~
sudo rm -rf /opt/mports


# ---------------------------------------------------------------------------
# install postgresql
# ---------------------------------------------------------------------------

sudo /opt/local/bin/port install postgresql84-server

sudo mkdir -p /opt/local/var/db/postgresql84/defaultdb
sudo chown postgres:postgres /opt/local/var/db/postgresql84/defaultdb
sudo su postgres -c '/opt/local/lib/postgresql84/bin/initdb -D /opt/local/var/db/postgresql84/defaultdb'


# modify pg logging
sudo sed -i -e 's/#client_min_messages = notice/client_min_messages = error/' \
  /opt/local/var/db/postgresql84/defaultdb/postgresql.conf

sudo sed -i -e 's/#log_min_messages = warning/log_min_messages = error/'  \
  /opt/local/var/db/postgresql84/defaultdb/postgresql.conf


# start pg via launchctl
sudo launchctl load -w /Library/LaunchDaemons/org.macports.postgresql84-server.plist
sudo /opt/local/etc/LaunchDaemons/org.macports.postgresql84-server/postgresql84-server.wrapper start


# add users to pg
sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s mms'
sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s jperkins'

sleep 1

# create the databases we'll need locally
/opt/local/lib/postgresql84/bin/createdb mms_development
/opt/local/lib/postgresql84/bin/createdb mms_test


# ---------------------------------------------------------------------------
# install other macports
# ---------------------------------------------------------------------------

sudo /opt/local/bin/port install watch
sudo /opt/local/bin/port install screen
sudo /opt/local/bin/port install bash-completion
sudo /opt/local/bin/port install git-core +bash_completion


# ---------------------------------------------------------------------------
# checkout a copy of transis
# ---------------------------------------------------------------------------

# mkdir -p ~/Centro
# cd ~/Centro
# git clone



# ---------------------------------------------------------------------------
# ~/.bash_profile mods
# ---------------------------------------------------------------------------

# if [ -f /opt/local/etc/bash_completion ]; then
#     . /opt/local/etc/bash_completion
# fi


# ---------------------------------------------------------------------------
# install gems
# ---------------------------------------------------------------------------

sudo gem update --system
sudo gem sources -a http://gems.github.com
sudo gem update outdated

# rake gems:install including the dev and test environments

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
# populate the database and run and pending migrations
# ---------------------------------------------------------------------------

# rake db:clone_production
# rake db:migrate

# rake test



