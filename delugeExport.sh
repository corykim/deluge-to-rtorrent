#!/bin/bash
####################################################################
###    Please create a delugeExport.settings file in the same
###    directory as this script
####################################################################

settings=`dirname "$0"`/delugeExport.settings
source "$settings"

###                                                              ###
# This script is designed to be used alongside the Execute plugin! #
###                                                              ###

####################################################################
###   Please remember to create the watch folder for rTorrent!   ###
###   Please remember to have rTorrent fully setup and config'd! ###
###   Remember to chmod  x this script and the perl script!      ###
####################################################################

function log(){
    if [ -n "$logfile" ]
    then
        timestamp=`date "+%m-%d-%y.%H.%M.%S"`
        echo "$timestamp  $@" >> $logfile
    fi
}

# Backup if you told it to.
date=`date "+%m-%d-%y.%H.%M.%S"`
if [ "$backup" = "yes" ]; then tar -cf $backup_path/deluge_state.$date.tar $files; fi

# Every torrent, "f", will have fastresume data added and then moved
# to rTorrent's watch directory, $watch, for addition.
#
# $1,$2 are received from Execute plugin. Need specifics when not en masse.
#
# If block ensures these lines don't run except via Execute plugin.
# - Authenticating to deluge-web.
# - Remove torrent using $1 var passed from Execute.
if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
    torrentid=$1
    torrentname=$2
    torrentpath=$3

    if [ -n "$sleep" ]
    then
            log "delugeExport.sh $@"
            log "Delaying by $sleep..."
            sleep $sleep
            log "... Resuming $@"
    fi

    log "Exporting $torrentname"
    perl $dir/rtorrent_fast_resume.pl "$torrentpath" < "$files/$torrentid.torrent" > "$watch/$torrentname.$RANDOM.torrent"
    cookie=`curl -vskm 1 -H "Content-Type: application/json" -X POST -d "{\"id\": 1,\"method\": \"auth.login\",\"params\": [\"$password\"]}" $scheme://$domain:$port/json 2>&1 | grep -i "Set-Cookie:" | cut -d '=' -f2 | cut -d ';' -f1`
    curl -vskm 1 -b _session_id=$cookie -H "Content-Type: application/json" -X POST -d "{\"method\":\"core.remove_torrent\",\"params\":[\"$1\",false],\"id\":2}" $scheme://$domain:$port/json
else
# Executed directly from command line.
# Migrate all torrents en masse. Do not remove torrents from Deluge.
#
    for f in $files/*.torrent
    do
      name=`basename $f`
      log "Exporting $name"
      perl $dir/rtorrent_fast_resume.pl $download < $f > $watch/$name
    done
fi