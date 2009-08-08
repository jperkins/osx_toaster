
## OS X Toaster

This script started as a means to automate James Duncan Davidson's,
["Sandboxing Rails With MacPorts."][1] Once that was done, I thought what would
be cool would be to automate the complete setup of a staging server and
subversion repository using a Mac Mini as the basis - similar to Matt
Simerson's [FreeBSD Mail Toaster] [2] scripts.

In writing this script, I've leaned considerably on Patrick Gibson's
[virtualhost.sh][3] script.


## A couple of years later...

I started work on this a couple of years ago and it's been sitting on my hard
drive collecting dust since. My original notion is the same: automating the
setup of an OS X computer for development. But when I began work on this, Chef
didn't exist. The plan now is to get this finished as a Bash script and then
port it to Chef.

I've managed to lose a couple of larger sections that dealt with the
configuration of MySQL and Subversion. My work is now nearly exclusively done
in Git, so anything Subversion specific that I add is going to reflect its
reduced role. I'm now using MySQL beside PostgreSQL and SQLite and expect
configs for those to be added in short order.

Finally, I have an alternate version of this for working with Snow Leopard's
betas. I'm not sure if that warrants its own file or incorporation with the
existing script. I'm leaning towards the latter.

Comments, suggestions, additions, etc. welcome.



[1] http://blog.duncandavidson.com/2006/04/sandboxing_rail.html
[2] http://matt.cadillac.net/computing/mail/toaster/
[3] http://patrickgibson.com/news/andsuch/000091.php