#!/usr/bin/env ruby -wKU


# ---------------------------------------------------------------------------
# ruby convenience methods
# ---------------------------------------------------------------------------

def rake command=nil
  puts "rake #{command}"
  puts `/usr/bin/rake #{command}`
end


def git command=nil
  puts "git #{command}"
  puts `/opt/local/bin/git #{command}`
end

def gem command=nil
  puts "gem #{command}"
  puts `/usr/bin/gem #{command}`
end


# ---------------------------------------------------------------------------
# test for sudo invocation
# ---------------------------------------------------------------------------

if [ `whoami` != 'root' ] ; then
  echo "This script must be invoked with sudo."
  exit 1
fi


# ---------------------------------------------------------------------------
# get username who invoked script
# ---------------------------------------------------------------------------

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
# macports install
# ---------------------------------------------------------------------------

sudo /opt/local/bin/port install bash-completion
sudo /opt/local/bin/port install bzip2
sudo /opt/local/bin/port install fetch
sudo /opt/local/bin/port install git-core +bash_completion
sudo /opt/local/bin/port install screen
sudo /opt/local/bin/port install watch
sudo /opt/local/bin/port install xtail


# ---------------------------------------------------------------------------
# get os x version
# ---------------------------------------------------------------------------

os_x_version = `sw_vers | grep 'ProductVersion:' | grep -o '[0-9]*\.[0-9]*'`


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


# TODO: add pg bin subdirectory to path in .bash_profile
# TODO: add aliases for pg_start, pg_stop, pg_restart to .bash_profile


# ---------------------------------------------------------------------------
# install gems
# ---------------------------------------------------------------------------

sudo gem update --system
sudo gem sources -a http://gems.github.com
sudo gem update outdated


# ---------------------------------------------------------------------------
# modify paths
# ---------------------------------------------------------------------------

# FIXME: we don't want $PATH evalutated when this script runs, but rather
# when /etc/bachrc is evaluated

# if [ ! -z $TESTING ]; then
#   if grep /etc/bashrc '/opt/local/bin'; then
#     echo "resetting /etc/bashrc"
#     mv /etc/bashrc.dist /etc/bashrc
#   fi
# fi

# PATH="/opt/local/bin:/opt/local/sbin:/opt/local/apache2/bin:${PATH}"

# add the following to the /etc/bashrc file:
# export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
# if ! grep /etc/bashrc '/opt/local/bin'; then
#   cp /etc/bashrc /etc/bashrc.dist
#   cat << __EOF > /etc/bashrc

# added by the mini toaster script so that ssh can find svnserve
# export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
# __EOF
# fi


# ---------------------------------------------------------------------------
# set system hostname and rendezous name
# ---------------------------------------------------------------------------

# TODO: setup rendevzous name

# if [ -z $HOSTNAME ]; then
#   scutil --set HostName $HOSTNAME
# fi


# ---------------------------------------------------------------------------
# ~/.bash_profile mods
# ---------------------------------------------------------------------------

# if [ -f /opt/local/etc/bash_completion ]; then
#     . /opt/local/etc/bash_completion
# fi


# ---------------------------------------------------------------------------
# centro config/setup
# ---------------------------------------------------------------------------

# sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s mms'
# sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s jperkins'

# /opt/local/lib/postgresql84/bin/createdb mms_development
# /opt/local/lib/postgresql84/bin/createdb mms_test

# do git clone from depot
# run geminstaller -c config/geminstaller.yml


