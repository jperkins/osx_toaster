#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# test for sudo invocation and get username who invoked script
# ---------------------------------------------------------------------------

if [ `whoami` != 'root' ] ; then
  echo "This script must be invoked with sudo."
  exit 1
fi


# ---------------------------------------------------------------------------
# create list of installed ports and then uninstall them
# ---------------------------------------------------------------------------

# http://www.mail-archive.com/macports-users@lists.macosforge.org/msg12138.html
# http://oleganza.tumblr.com/post/127709563/snow-leopard-with-legacy-macports-and-rubygems

# if [ -d /opt/local ]; then
  /opt/local/bin/port installed | sed 's/(active)$//' | sed 's/^/install/' | grep -v 'The following' > installed_ports
  sudo /opt/local/bin/port -f uninstall installed
  sudo rm -rf /opt/local
# fi


# ---------------------------------------------------------------------------
# install macports
# ---------------------------------------------------------------------------

# http://guide.macports.org/#installing.macports.subversion

sudo mkdir -p /opt/mports
cd /opt/mports

sudo svn checkout http://svn.macports.org/repository/macports/trunk/base

cd ./base/
sudo ./configure --enable-readline
sudo make
sudo make install

sudo /opt/local/bin/port -v selfupdate

cd ~
sudo rm -rf /opt/mports


# ---------------------------------------------------------------------------
# reinstall apps from macports
# ---------------------------------------------------------------------------

/opt/local/bin/port -F installed_ports

# sudo /opt/local/bin/port install bash-completion
# sudo /opt/local/bin/port install bzip2
# sudo /opt/local/bin/port install fetch
# sudo /opt/local/bin/port install git-core +bash_completion
# sudo /opt/local/bin/port install screen
# sudo /opt/local/bin/port install watch
# sudo /opt/local/bin/port install xtail


# ---------------------------------------------------------------------------
# setup postgresql
# ---------------------------------------------------------------------------

# sudo /opt/local/bin/port install postgresql84-server

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
# centro config/setup
# ---------------------------------------------------------------------------

sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s mms'
sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s jperkins'

/opt/local/lib/postgresql84/bin/createdb mms_development
/opt/local/lib/postgresql84/bin/createdb mms_test

# do git clone from depot
# run geminstaller -c config/geminstaller.yml


# ---------------------------------------------------------------------------
# reinstall gems
# ---------------------------------------------------------------------------

sudo gem update --system

gem list | cut -d" " -f1 > installed_gems
sudo mv /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8 \
  /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8.bak

sudo mkdir /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8
sudo gem list | cut -d" " -f1 | xargs sudo gem uninstall -aIx

cat installed_gems | xargs sudo env ARCHFLAGS="-Os -arch x86_64 -fno-common" gem install


# ---------------------------------------------------------------------------
# install gems
# ---------------------------------------------------------------------------

# http://www.schmidp.com/2009/06/24/building-the-postgres-gem-for-a-64bit-postgresql-on-snow-leopard-10-6/
sudo env ARCHFLAGS="-arch x86_64" gem install pg

# http://www.schmidp.com/2009/06/14/rubyrails-and-mysql-on-snow-leopard-10a380/
# sudo env ARCHFLAGS="-Os -arch x86_64 -fno-common" gem install mysql — –with-mysql-config=/usr/local/mysql/bin/mysql_config

# You can use these flags for jscruggs-metric_fu too :
# sudo env ARCHFLAGS="-Os -arch x86_64 -fno-common" gem install jscruggs-metric_fu




