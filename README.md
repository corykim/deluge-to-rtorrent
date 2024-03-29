# deluge-to-rtorrent
Script to automatically export from Deluge to rTorrent

This script is almost entirely derived from Lewis Miller's blog, "freshly squeezed." The original source can be found [here](http://theendoftheuniver.se/ramblings/automatically-transfer-torrents-from-deluge-to-rtorrent/).

## Dependencies

- perl
- `Convert::Bencode`: to install this should run:

	```
	sudo perl -MCPAN -e 'install Convert::Bencode'
	```

- Deluge
- rTorrent:
	- You will want to set up a watch folder in rTorrent
- rtorrent_fast_resume.pl located in the [rtorrent repo](https://github.com/rakshasa/rtorrent/blob/master/doc/rtorrent_fast_resume.pl) Note: If you have trouble install `Convert::Bencode_XS` you should change the import to `Convert::Bencode`

## Installation

1. Add the `delugeExport.sh` file to your file system.
2. Make sure to make the script executable using `chmod +x delugeExport.sh`
2. Copy the file `delugeExport.settings.template` to `delugeExport.settings` and
   fill in all of the settings as needed.
2. Enable the Execute plugin in Deluge.
2. Add a command on the event "Torrent Complete", to execute the name of your script.
2. You may need to restart Deluge in order for the Execute plugin to register your command.

## Operation

1. Whenever a torrent completes, Deluge will execute the script.
2. The script will sleep for however long you request before moving further.
2. The script will add fast resume data to the torrent.
3. The script will send the torrent to rTorrent's watch directory.
3. The script will login to Deluge and remove the torrent.

## Command Line Operation

You can execute the command `delugeExport.sh` manually from a command line. The script will then export every torrent that is currently in Deluge. The exported torrents will *not* be removed from Deluge.