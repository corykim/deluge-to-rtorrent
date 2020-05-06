#!/bin/bash
####################################################################
###             Please fill in the variables below!              ###
####################################################################

# !! Important: create a script `perlenv` that contains the environment
# variables that bash needs to properly execute perl. You should be
# able to find an example in your own .bashrc or .bash_profile
source $HOME/bin/perlenv

# Delay the script by this amount before running. This is useful if 
# you want deluge to continue seeding for some time before moving the torrent.
# Use any standard bash sleep duration such as 60s, 10m, 3h, 1d, etc.
sleep=

# Default is "deluge", but you should have changed it...
password=deluge

# Your domain/IP here. For example, google.com or localhost or 127.0.0.1
domain=localhost

# The port you use to access the WebUI (default 8112)
port=8112

# Do you use http or https to access the WebUI (default http)?
scheme=http

# Which folder are you keeping rtorrent_fast_resume.pl in?
# Please include trailing slash.
dir=$HOME/bin/

# Where do your torrents eventually download to? If they auto-move
# please specify that directory. Please include trailing slash.
#download=$HOME/files/
download=$HOME/files/

# rTorrent's watch folder. Please include trailing slash.
watch=$HOME/rtorrent-watch/

# Do you want to backup whatever's in Deluge's state directory before
# you rm it all? (Maybe useful the first time for the mass-transfer
# just to be sure but probably not afterward).
backup=yes
backup_path=$HOME/deluge-backups/

# Do not change this unless you have knowingly changed Deluge's
# state folder.
files=$HOME/.config/deluge/state/

logfile=$HOME/log/delugeExport.log

###							         ###
# This script is designed to be used alongside the Execute plugin! #
###								 ###

####################################################################
###   Please remember to create the watch folder for rTorrent!   ###
###   Please remember to have rTorrent fully setup and config'd! ###
###   Remember to chmod  x this script and the perl script!	 ###
####################################################################

# Backup if you told it to.
date=`date "+%m-%d-%y.%H.%M.%S"`
if [ "$backup" = "yes" ]; then tar -cf $backup_path/deluge_state.$date.tar $files; fi

if [ -n "$sleep" ]
then
	echo "$date: ~/bin/delugeExport.sh $@" >> $logfile
	echo "Delaying by $sleep..." >> $logfile
	sleep $sleep
	echo "... Resuming $@" >> $logfile
fi

# Every torrent, "f", will have fastresume data added and then moved
# to rTorrent's watch directory, $watch, for addition.
# $1,$2 received from Execute plugin. Need specifics when not en masse.
# If block ensures these lines don't run except via Execute plugin.
# Authenticating to deluge-web.
# Remove torrent using $1 var passed from Execute.
if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
	torrentid=$1
        torrentname=$2
        torrentpath=$3
	
	perl $dir/rtorrent_fast_resume.pl "$torrentpath" < "$files/$torrentid.torrent" > "$watch/$torrentname.$RANDOM.torrent"
        cookie=`curl -vskm 1 -H "Content-Type: application/json" -X POST -d "{\"id\": 1,\"method\": \"auth.login\",\"params\": [\"$password\"]}" $scheme://$domain:$port/json 2>&1 | grep -i "Set-Cookie:" | cut -d '=' -f2 | cut -d ';' -f1`
	curl -vskm 1 -b _session_id=$cookie -H "Content-Type: application/json" -X POST -d "{\"method\":\"core.remove_torrent\",\"params\":[\"$1\",false],\"id\":2}" $scheme://$domain:$port/json
else
	for f in $files/*.torrent
        do
          name=`basename $f`
          perl $dir/rtorrent_fast_resume.pl $download < $f > $watch/$name
        done
fi
