# MPRIS CLI Operation

To control player (spotify,cmus,VLC) in command line on GNU/Linux, we can use command `dbus-send` to send a message to a [D-Bus][dbus] message bus.

The *Media Player Remote Interfacing Specification* ([MPRIS][MPRIS][mpris_spec]) is a standard D-Bus interface which aims to provide a common programmatic API for controlling media players. It provides a mechanism for discovery, querying and basic playback control of compliant media players, as well as a tracklist interface which is used to add context to the active media item.


## TOC

1. [Documentation](#documentation)  
2. [D-Bus Operation](#d-bus-operation)  
2.1 [Freedesktop D-Bus](#freedesktop-d-bus)  
2.2 [MediaPlayer2.Player](#mediaplayer2player)  
3. [Change Log](#change-log)  


## Documentation

* https://specifications.freedesktop.org/mpris-spec/latest/
* https://dbus.freedesktop.org/doc/dbus-specification.html
* https://wiki.archlinux.org/index.php/Spotify
* https://wiki.archlinux.org/index.php/Music_Player_Daemon


## D-Bus Operation

Project [omxplayer/dbuscontrol.sh](https://github.com/popcornmix/omxplayer/blob/master/dbuscontrol.sh) list commands of MPRIS DBus operation.


### Freedesktop D-Bus

[D-Bus Specification](https://dbus.freedesktop.org/doc/dbus-specification.html)

list available D-Bus names

```bash
# system D-Bus list
dbus-send --system --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListActivatableNames

# session D-Bus list
dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListActivatableNames

dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames
# string "org.mpris.MediaPlayer2.spotify"
# string "org.mpris.MediaPlayer2.cmus"
```

just list D-Bus names using *org.mpris.MediaPlayer2*

```bash
dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames | sed -r -n '/org.mpris.MediaPlayer2/{s@.*org.mpris.MediaPlayer2.([^"]+).*@\1@g;p}'

# spotify
# cmus
```

list process id via D-Bus name

```bash
dbus-send --print-reply --dest=org.freedesktop.DBus / org.freedesktop.DBus.GetConnectionUnixProcessID string:'org.mpris.MediaPlayer2.spotify'

# -s, --single-shot    return one PID only
pidof -s spotify
```


### MediaPlayer2.Player

[Player_Interface](https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html)

Command line to control player.

```bash
# For true players: vlc/cmus/audacious/bmp/xmms2/spotify and others.
player_name=${player_name:-'spotify'}

mpris_bus_name="org.mpris.MediaPlayer2.${player_name}"
mpris_entry_point='/org/mpris/MediaPlayer2'
mpris_interface='org.mpris.MediaPlayer2.Player'

# dbus-send
# --system   Send to the system message bus.
# --session  Send to the session message bus. (This is the default.)
```

current track metadata

```bash
# dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Get string:"${mpris_interface}" string:'Metadata'
```

Play status (Playing|Paused|Stopped)

```bash
# dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'
# sed -r -n '/variant/{s@.*string[[:space:]]+"([^"]+).*@\1@g;p}'
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Get string:"${mpris_interface}" string:'PlaybackStatus'
```

Position

```bash
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Position'
#sed -r -n '/variant/{s@.*int[[:digit:]]+[[:space:]]*([[:digit:]]+)0{6}.*@\1@p}'
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Get string:"${mpris_interface}" string:'Position'

# set position (microseconds)
# https://github.com/popcornmix/omxplayer/issues/559
dbus-send --session --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.SetPosition objpath:'/3' int64:128000000
# /3 is mpris:trackid from Metadata

# seek (microseconds)
dbus-send --session --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Seek int64:8000000
dbus-send --session --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Seek int64:-8000000
```

Play/Pause/Stop/PlayPause

```bash
# Play
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Play
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Play

# Pause
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Pause

# Stop
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Stop

# Toogle Play/Pause
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.PlayPause
```

Next track

```bash
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Next
# Previous track
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.Previous
```

Open Url

```bash
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri string:"https://open.spotify.com/track/4y5BMsysQoqkovNtl71F0u"
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} ${mpris_interface}.OpenUri string:"https://open.spotify.com/track/4y5BMsysQoqkovNtl71F0u"
```

Volume Control

```bash
# Get current volume
#dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Volume'
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Get string:"${mpris_interface}" string:'Volume'

# Set Volume (min 0.0 to max 1.0)
#dbus-send --print-reply --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:'org.mpris.MediaPlayer2.Player' string:'Volume' variant:double:0.0
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Set string:"${mpris_interface}" string:'Volume' variant:double:0.0
#dbus-send --print-reply --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:'org.mpris.MediaPlayer2.Player' string:'Volume' variant:double:1.0
dbus-send --print-reply --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Set string:"${mpris_interface}" string:'Volume' variant:double:1.0
```

Shuffle

```bash
#dbus-send --print-reply --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:'org.mpris.MediaPlayer2.Player' string:'Shuffle' variant:boolean:true

dbus-send --print-reply -type=method_call --dest=${mpris_bus_name} ${mpris_entry_point} org.freedesktop.DBus.Properties.Set string:"${mpris_interface}" string:'Shuffle' variant:boolean:true
```


## Change Log

* Jun 10, 2020 Wed 15:00 ET
  * first draft
* Jun 15, 2020 Mon 13:33 ET
  * add section *Freedesktop D-Bus*, list D-Bus names
* Jun 16, 2020 Tue 16:36 ET
  * add personal shell script [mpris player control](./mpris_player_control)
* Jun 18, 2020 Thu 16:03 ET
  * add Web brower support


[mpris_spec]:https://specifications.freedesktop.org/mpris-spec/latest/ "MPRIS D-Bus Interface Specification"
[dbus]:https://www.freedesktop.org/wiki/Software/dbus/ "D-Bus is a message bus system, a simple way for applications to talk to one another."
[playerctl]:https://github.com/altdesktop/playerctl "mpris command-line controller and library for vlc, audacious, bmp, cmus, spotify and others."


<!-- End -->