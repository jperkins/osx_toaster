#!/usr/bin/env bash


# add test for and bail with error msg if prerequisites aren't met
#
# prerequisites:
#   - os x developer tools




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


# ---------------------------------------------------------------------------
# install other macports
# ---------------------------------------------------------------------------

sudo /opt/local/bin/port install watch
sudo /opt/local/bin/port install screen
sudo /opt/local/bin/port install bash-completion
sudo /opt/local/bin/port install git-core +bash_completion



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








