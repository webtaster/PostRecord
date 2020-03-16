#!/bin/bash

#
# Quick script to postprocess TV recordings with comskip.
#


LOG=/home/osmc/scripts/log
COMSKIP=/usr/local/bin/comskip
INI=/home/osmc/comskip.ini
ADMIN=your.email@address.com

tmpfile=$(mktemp /tmp/postprocess.XXXXXX)

cat <<EOF >> $tmpfile

$(date) Recording completed:
Name:     $1
Subtitle: $2
Desc:     $3
Channel:  $4
Episode:  $5
Type:     $6
Streams:  $7
Comment:  $8
Error:    $9
Path:     ${10}
EOF

channel=$4



#
# Run comskip on recording file to remove add breaks.  Not if it is a BBC channel,
# though, as they have no commercial breaks.
#
if [[ -z $(grep -i bbc <<< $channel) ]]
then

   echo                                                                        >> $tmpfile
   $COMSKIP --ini $INI  "${10}" 2>&1 | 
      egrep -i "frames decoded|$COMSKIP|commandline|commercials" >> $tmpfile
   echo                                                                        >> $tmpfile

else
   echo                                                                         >> $tmpfile
   echo "Channel appears to be BBC.  Not running comskip as no commercials."    >> $tmpfile
   echo                                                                         >> $tmpfile
fi


cat $tmpfile >> $LOG
cat $tmpfile | mailx -s "Recorded $1" $ADMIN
rm $tmpfile

#
# From TVHeadend built-in help:
#
# Format 	Description 		Example value
# %f 	Full path to recording 		/home/user/Videos/News.mkv
# %b 	Basename of recording 		News.mkv
# %c 	Channel name 			BBC world
# %O 	Owner of this recording 	user
# %C 	Who created this recording 	user
# %t 	Program title 			News
# %s 	Program subtitle 		Afternoon
# %p 	Program episode 		S02.E07
# %d 	Program description 		News and stories…
# %g 	Program content type 		Current affairs
# %e 	Error message 			Aborted by user
# %S 	Start time stamp of recording, UNIX epoch 	1224421200
# %E 	Stop time stamp of recording, UNIX epoch 	1224426600
# %r 	Number of errors during recording 	0
# %R 	Number of data errors during recording 	6
# %i 	Streams (comma separated) 	H264,AC3,TELETEXT
# %Z 	Comment 	A string
#
