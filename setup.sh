#!/usr/bin/env bash
# Copyright © 2009 Jason Perkins <jperkins@sneer.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or
# implied warranty.


# ---------------------------------------------------------------------------
# test for sudo invocation and get username who invoked script
# ---------------------------------------------------------------------------

if [ `whoami` != 'root' ] ; then
  echo "This script must be invoked with sudo."
  exit 1
fi

if [ -z $USER -o $USER = "root" ]; then
	if [ ! -z $SUDO_USER ]; then
		USER=$SUDO_USER
	else
		USER=""
		echo "ALERT! Your root shell did not provide your username."
		while : ; do
			if [ -z $USER ]; then
				while : ; do
					echo -n "Please enter *your* username: "
					read USER
					if [ -d /Users/$USER ]; then
						break
					else
						echo "$USER is not a valid username."
					fi
				done
			else
				break
			fi
		done
	fi
fi

if [ -z $DOC_ROOT_PREFIX ]; then
	DOC_ROOT_PREFIX="/Users/$USER/Sites"
fi


# ---------------------------------------------------------------------------
# modify paths
# ---------------------------------------------------------------------------

# FIXME: we don't want $PATH evalutated when this script runs, but rather
# when /etc/bachrc is evaluated

if [ ! -z $TESTING ]; then
	if grep /etc/bashrc '/opt/local/bin'; then
		echo "resetting /etc/bashrc"
		mv /etc/bashrc.dist /etc/bashrc
	fi
fi

PATH="/opt/local/bin:/opt/local/sbin:/opt/local/apache2/bin:${PATH}"

# add the following to the /etc/bashrc file:
# export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
if ! grep /etc/bashrc '/opt/local/bin'; then
	cp /etc/bashrc /etc/bashrc.dist
	cat << __EOF > /etc/bashrc

# added by the mini toaster script so that ssh can find svnserve
export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
__EOF
fi


# ---------------------------------------------------------------------------
# set system hostname and rendezous name
# ---------------------------------------------------------------------------

# TODO: setup rendevzous name

if [ -z $HOSTNAME ]; then
	scutil --set HostName $HOSTNAME
fi


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
# install apps via darwinports
# ---------------------------------------------------------------------------

port install mysql5 +server
port install subversion +tools -no_bdb
port install bash-completion
port install bzip2
port install fetch
port install xtail
port install screen


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








