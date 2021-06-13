#!/bin/bash
# Sync ROMs from network directory.
# Version 1.0.0, c/o Wyrrrd
# 09.06.2021
echo "# retropie_sync"
echo "# Sync ROMs from other directory."
echo "# Version 1.0.0, c/o Wyrrrd"
echo "# 09.06.2021"

romspath="/home/pi/RetroPie/roms"
metapath="/home/pi/.emulationstation"
systems=("gb" "gbc" "gba" "nes" "snes")
restart=false
retries=10
retryinterval=10

. $(dirname $0)/retropie_sync.conf

if [[ -z $sourcepath ]]
then
  for (( i=0; $i<=$retries; i++ ))
  do
    if [[ -z $sourcepath && "$(ls -A $sourcepath)" ]]
    then
      echo "Source path is not empty. Starting sync."
      len=${#systems[@]}
      for (( j=0; $j<$len; j++ ))
      do
        system=${systems[j]}
        if [[ "$ls -A $sourcepath/$system)" ]]
        then
          echo "Syncing system $system ($((j+1))/$len)"
          
          if [[ -z $romspath ]]
          then
            echo "  - Syncing ROMs"
            mkdir -p $romspath/$system
            [[ $(rsync -aiz --delete $sourcepath/$system/* $romspath/$system) ]] && changes=true
          fi

          if [[ -z $metapath ]]
          then
            echo "  - Syncing gamelist"
            mkdir -p $metapath/gamelists/$system
            [[ $(rsync -aiz --delete $sourcepath/.emulationstation/gamelists/$system/* $metapath/gamelists/$system) ]] && changes=true
                
            echo "  - Syncing boxarts"
            mkdir -p $metapath/downloaded_images/$system
            [[ $(rsync -aiz --delete $sourcepath/.emulationstation/downloaded_images/$system/* $metapath/downloaded_images/$system) ]] && changes=true
          fi
        fi
      done
      echo "Sync completed."

      if [[ $changes ]]
      then
        echo "There are changes. Playing change laser."
        aplay $(dirname $0)/done.wav > /dev/null
      fi

      if [[ $retries -gt 0 ]]
      then
        echo "$i of $retries retries needed."
      fi

      break
    else
      echo "Source path is empty. Not syncing to avoid data loss."
      if [[ $retries -gt 0 ]]
      then
        echo " - Retrying in $retryinterval seconds."
        sleep 10
      else
        break
      fi
    fi
  done
else
  echo "Source path not set, aborting."
fi