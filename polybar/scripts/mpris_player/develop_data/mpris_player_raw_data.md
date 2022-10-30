# MPRIS Player Raw Data Collection

The following raw datas are used to organize function **fn_DBus_Sink_Relation_Table** in script [mpris_player_control](./mpris_player_control).


## TOC

1. [Script Command](#script-command)  
2. [Media Player](#media-player)  
2.1 [Spotify](#spotify)  
2.2 [VLC](#vlc)  
2.3 [cmus](#cmus)  
3. [Web Browser](#web-browser)  
3.1 [Mozilla Firefox](#mozilla-firefox)  
3.2 [Google Chrome](#google-chrome)  
3.3 [Chroimum Derivatives](#chroimum-derivatives)  
3.4 [Chroimum](#chroimum)  
3.4.1 [Brave](#brave)  
3.4.2 [SRWare Iron](#srware-iron)  


## Script Command

The following commands are used to extract relevant info about Mpris Players.

MPRIS DBus List

```bash
dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames | sed -r -n '/org.mpris.MediaPlayer2/{s@.*org.mpris.MediaPlayer2.([^"]+).*@\1@g;p}'
```

Player Sink Info

```bash
pactl list sink-inputs 2> /dev/null | sed -r -n '/^Sink Input/{s@^[^#]+#@@g;p};/^[[:space:]]*(application.name|application.process.binary|application.process.id)/{s@^[^=]+=[[:space:]]*@@g;s@"@@g;p};/^[[:space:]]*(Mute|Corked):/{s@^[^:]+:[[:space:]]*@@g;p};/^[[:space:]]*Volume:/{s@.*?[[:space:]]+([[:digit:]]+)%.*@\1@g;p};/^$/{s@.*@---@g;p}' | sed ':a;N;$!ba;s@\n@|@g' | sed -r -n 's@\|?---\|?@\n@g;p'

# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
# 1 sink num| 2 corked (playpause)|3 is muted|4 volume| 5 app name|6 processid|7 binary name|
```

Process Info

```bash
ps --no-headers -e -o '%p|%P|%c|%a' 2> /dev/null | sed -r -n 's@^[[:space:]]*@@g;s@[[:space:]]*(\|)[[:space:]]*@\1@g;p'

# %p pid PID / %P ppid PPID / %U user USER / %a args COMMAND / %c comm COMMAND
# 1 pid| 2 ppid| 3 binary name| 4 command
```

## Media Player

### Spotify

```bash
# Mpris DBus list
spotify

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
128|no|no|100|Spotify|1247194|spotify

# Process Info
1247194|1|spotify|/opt/spotify/spotify --force-device-scale-factor=2
1247197|1247194|spotify|/opt/spotify/spotify --type=zygote... --lang=en-US
```

### VLC

```bash
# Mpris DBus list
vlc

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
129|no|no|180|VLC media player (LibVLC 3.0.11)|1253746|vlc

# Process Info
1253746|1|vlc|/usr/bin/vlc --started-from-file
```

### cmus

```bash
# Mpris DBus list
cmus

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
130|no|no|155|C* Music Player|1254697|cmus

# Process Info
1254697|728518|cmus|cmus
```

## Web Browser

### Mozilla Firefox

```bash
# Mpris DBus list
firefox.instance1238573

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
125|no|no|100|Firefox|1238573|firefox-bin

# Process Info
1238573|1|firefox-bin|firefox --new-tab https://duckduckgo.com
```

### Google Chrome

```bash
# Mpris DBus list
chrome.instance1236726

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
123|no|no|170|Google Chrome|1237018|chrome

# Process Info
1236726|1|chrome|/opt/google/chrome/chrome
1237018|1236726|chrome|/opt/google/chrome/chrome --type=utility ...--shared-files
```

### Chroimum Derivatives

### Chroimum

```bash
# Mpris DBus list
chromium.instance1244602

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
127|no|no|185|Chromium|1244873|chromium

# Process Info
1244602|1|chromium|/usr/lib/chromium/chromium
1244873|1244602|chromium|/usr/lib/chromium/chromium --type=utility...--shared-files
```

#### Brave

```bash
# Mpris DBus list
chromium.instance1243900

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
126|no|no|185|Chromium|1244265|brave

# Process Info
1243900|1243895|brave|/usr/lib/brave-bin/brave
1244265|1243900|brave|/usr/lib/brave-bin/brave --type=utility...--shared-files
```

#### SRWare Iron

```bash
# Mpris DBus list
chromium.instance1237985

# Player Sink Info
# sink num|corked (playpause)|is muted|volume|app name|process id|binary name
124|no|no|185|Chromium|1238308|chrome

# Process Info
1237985|1|chrome|/opt/SRWareIron/chrome
1238308|1237985|chrome|/opt/SRWareIron/chrome --type=utility ... --shared-files=v8_snapshot_data:100
```


<!-- End -->