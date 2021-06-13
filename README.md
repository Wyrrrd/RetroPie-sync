# RetroPie-sync

## Description
Syncs your ROMs and metadata from a network (or any other) directory.
Be careful with this quick hacky script, it might stir up or delete your ROMs, gamelists and boxarts if you are not careful. Always backup and test. Use read-only where possible. Read "[Known Issues](#known-issues)" below.

## Setup
### Configuration Options
Configurations are made in the file `retropie_sync.conf`. The following options have to be set for the script to work.

| Parameter     | Usage                                                                                                  | Default                                 |
| ---           | ---                                                                                                    | ---                                     |
| sourcepath    | path your data will be synced from (should be read-only)                                               | -                                       |
| romspath      | path your ROMs will be synced to, empty disables this                                                  | romspath="/home/pi/RetroPie/roms"       |
| metapath      | path your EmulationStation metadata will be synced to, empty disables this                             | metapath="/home/pi/.emulationstation"   |
| systems       | list of systems to sync data for                                                                       | systems=("gb" "gbc" "gba" "nes" "snes") |
| restart       | if EmulationStation should be restarted on changes (hacky, read "[Known Issues](#known-issues)" below) | restart=false                           |
| retries       | number of retries until script stops for good, set to 0 if using local sync                            | retries=10                              |
| retryinterval | number of seconds between retries                                                                      | retryinterval=10                        |

### Intended Setup
I wrote this script for a [PiBoy DMG](https://www.experimentalpi.com/PiBoy-DMG--Full-Kit_p_18.html), but keep my master ROMs directory on a CIFS network share in my home network. The following steps are needed to replicate my setup, which I tested, works for me :)

#### Network directory setup
If ROM sync is enabled, this script expects your ROMs to be sorted on your network share as they would be in RetroPie (separated by subfolders named after their respective systems). More nested folders inside of those (e.g. "Romhacks", "Pokemon" etc.) are okay.
Additionally, if metadata sync is enabled, the script expects a directory `.emulationstation` in the network share root, that contains subfolders for gamelists and downloaded images. You can copy them from your RetroPie under `/home/pi/.emulationstation/gamelists` and `/home/pi/.emulationstation/downloaded_images`.

#### Move Savestates and Savegames
Savestates and savegames are normally stored in `/home/pi/RetroPie/roms`. Since we want to sync ROMs to that directory, we need to move them.
Connect to your RetroPie via SSH.

```
mkdir /home/pi/RetroPie/saves
find $directory -type f -name "*.srm" -or -name "*.sav" -or -name "*.state*" -exec mv {} /home/pi/RetroPie/saves/ \;
```

Then, in EmulationStation, open Retroarch Settings, go to "Settings" &#8594; "Directories" and set both "Savegames" and "Savestates" to `/home/pi/RetroPie/saves`.
Go to "Settings" &#8594; "Configuration", check "Save configuration on exit", then exit.

#### Install RetroPie-sync
```
cd /home/pi
git clone https://github.com/Wyrrrd/RetroPie-sync
```

#### Install autofs
```
sudo apt-get install autofs
```

#### Configure autofs
Add the following line to `/etc/auto.master`:
```
/media/cifs /etc/auto.cifs-shares --timeout=60 --ghost
```

Add the file `/etc/auto.cifs-shares` with the following contents:
```
roms -fstype=cifs,uid=1000,credentials=/home/pi/.smbcredentials,ro ://path.to/network/share
```

Add the file `/home/pi/.smbcredentials` with your read-only network share credentials:
```
username=changeme
password=changeme
```

#### Make RetroPie-sync autostart

Add the following line to `/opt/retropie/configs/all/autostart.sh`, as first line before everything else:
```
/home/pi/RetroPie-sync/retropie_sync.sh &
```

### Known Issues
- [ ] Gamelists are not being merged. If EmulationStation updates local gamelist, older but more up to date remote gamelist might not be synced. 
- [ ] Even if gamelists are synced, "LastPlayed" info is lost.
- [ ] Only sound to signal changes to the user is not sufficient, adding a visual notification would be better.
- [ ] EmulationStation restart is hacky. If a game is started, and quit after EmulationStation restart, Retropie doesn't find it's way back to EmulationStation.

## Credits
The sound `done.wav` is "[Laser Cannon](https://soundbible.com/1771-Laser-Cannon.html)" by Mike Koenig, which is licensed under [Attribution 3.0](https://creativecommons.org/licenses/by/3.0/). Though the file was renamed, the sound within was not modified.