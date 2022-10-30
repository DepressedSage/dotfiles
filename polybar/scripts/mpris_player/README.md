# MPRIS Player Control

To control player (spotify,cmus,VLC) in command line terminal on GNU/Linux, utility [altdesktop/playerctl][playerctl] is a good solution.

My initial personal requirement is control Spotify sink volume, but [altdesktop/playerctl][playerctl] doesn't work. After I knew command `dbus-send` can send a message to a [D-Bus][dbus] message bus directly and command `pactl` can control sink volume. I decided to build a solution to act like [altdesktop/playerctl][playerctl] from scratch.

Shell script [mpris_player_control] can be used alone. With [polybar/mpris_module][mpris_module], it can also works with status bar [Polybar][polybar].


## TOC

1. [Overview](#overview)  
1.1 [Video demo](#video-demo)  
2. [Project Explanation](#project-explanation)  
2.1 [Script Features](#script-features)  
2.2 [Script Dependency](#script-dependency)  
2.3 [Script Usage](#script-usage)  
3. [Polybar Support](#polybar-support)  
4. [Music Streaming Platform Support](#music-streaming-platform-support)  
4.1 [For Tidal](#for-tidal)  
4.2 [For Spotify](#for-spotify)  
4.2.1 [Advertisement mute](#advertisement-mute)  
5. [Web Browser Support](#web-browser-support)  
6. [Different with playerctl](#different-with-playerctl)  
7. [Bibliography](#bibliography)  
8. [Change Log](#change-log)  


## Overview

Personal laptop environment is [Arch Linux][archlinux] + [i3][i3] + [Polybar][polybar], Polybar mpris bar is on the bottom of the screen.

<details>
<summary>Click to expand desktop snapshot</summary>

![i3 desktop overview](https://gitlab.com/axdsop/nixnotes/raw/image/blob-image/Linux/ArchLinux/i3/overview/2020-07-01-101922_i3_desktop_overview.png)

</details>
<details>
<summary>Click to expand Polybar MPRIS bar snapshot</summary>

![mpris players demo image](https://gitlab.com/axdsop/nixnotes/raw/image/blob-image/Linux/ArchLinux/i3/mpris_player/demo_mpris_player.png)

</details>


### Video demo

Video|Youtube
---|---
mpris-player-control demo|[Youtube](https://www.youtube.com/watch?v=f_FhpHDlt3M)

<!-- <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/f_FhpHDlt3M" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe> -->

[![mpris-player-control demo](https://img.youtube.com/vi/f_FhpHDlt3M/hqdefault.jpg 'mpris-player-control demo')](https://www.youtube.com/watch?v=f_FhpHDlt3M)


## Project Explanation

Note: This project is part of my project [Unix-like Dotfiles](https://gitlab.com/axdsop/nix-dotfiles) hosted on GitLab.

>The *Media Player Remote Interfacing Specification* ([MPRIS][mpris_spec]) is a standard [D-Bus][dbus] interface which aims to provide a common programmatic API for controlling media players. It provides a mechanism for discovery, querying and basic playback control of compliant media players, as well as a tracklist interface which is used to add context to the active media item.

This project includes the following files.

No|Item|Explanation
---|---|---
1|[mpris_player_control.sh][mpris_player_control]|Shell script control MPRIS player
2|[develop_data/mpris_cli_operation.md](./develop_data/mpris_cli_operation.md)| `dbus-send` command samples, used to customsize development
3|[develop_data/mpris_player_raw_data.md](./develop_data/mpris_player_raw_data.md)| MPRIS Player Raw Data Collection (DBus/Sink/Process), used to customsize development
4|[polybar/mpris_module][mpris_module]|MPRIS modules for Polybar
5|[polybar/bar_module_position_mpris][mpris_position]|modules position for bar mpris on bottom
6|[polybar/bars][polybar_bar_entry]|Polybar bar configuration sample
Configs/polybar/includes/bar_entry.ini

### Script Features

1. Support media player implement with MPRIS DBus interface (VLC/cmus/Spotify/Audacious/Clementine/Rhythmbox ...);
2. Support Web browser (Google Chrome/Chromium/Brave/Mozilla Firefox ...);
3. Support play action (Play/Pause/PlayPause/Stop);
4. Support track position seek (backward/forward), position set;
5. Support player sink volume action (mute/unmute/up/down);
6. Support current track info display via notification deamon;
7. Support track metedata info list;
8. Support player session reset;
9. Support multi players selection menu when session is empty;
10. Support current player instance process kill;
11. Support Spotify official client advertisement mute until normal track playing (just click 'next' icon (uf9ab) on Polybar mpris bar);
12. Polybar mpris bar show/hide/restart action;
13. Notification with corresponding player icon if existed in icon theme *Papirus*;


### Script Dependency

Script [mpris_player_control][mpris_player_control] requires utility `sed`,`gawk`,`pactl`.

If you just wanna it work like [altdesktop/playerctl][playerctl], no other utility needs.

If you wanna control player sink volume , you need utility `pactl` provided by package *pulseaudio*.

**But** if you wanna make full use of it with status bar [Polybar][polybar], you need to install the following packages.

Type|Project|Functions provide
---|---|---
Status bar|[Polybar](https://github.com/polybar/polybar)|status bar
Iconic font|[Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)|Polybar mpris modules icon
Notification daemon|[Dunst](https://github.com/dunst-project/dunst)|Configure notification dialog preferences include icon path
Icon theme|[Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)|Provide icons used by notification daemon `notify-send`
dmenu replacement|[Rofi](https://github.com/davatorium/rofi)|Running players instance menu choose
Sound server|[PulseAudio](https://wiki.archlinux.org/index.php/PulseAudio)|Provides utility `pactl` to control sink volume

For Arch Linux, installation commands

```bash
# PulseAudio
sudo pacman -R --noconfirm pulseaudio

# Polybar
yay -S --noconfirm polybar

# Nerd font
yay -S --noconfirm nerd-fonts-source-code-pro

# Rofi
sudo pacman -S --noconfirm rofi

# Dunst
sudo pacman -R --noconfirm dunst

# Papirus
# Icon theme dir /usr/share/icons/
# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
sudo pacman -S papirus-icon-theme
```

To enable notification icon theme *Papirus* in *Dunst*, change configuration file *dunstrc* (Default is `~/.config/dunst/dunstrc`)

```ini
### Icons ###

# Align icons left/right/off
icon_position = left

# Scale larger icons down to this size, set to 0 to disable
max_icon_size = 256 # 32

# Paths to default icons.
; /usr/share/icons/gnome/48x48/status/:/usr/share/icons/gnome/48x48/devices/
icon_path = /usr/share/icons/Papirus/96x96/devices/:/usr/share/icons/Papirus/48x48/status/:/usr/share/icons/Papirus/96x96/apps/
```


### Script Usage

Listing help info via

```bash
bash mpris_player_control -h
```

More specific usages see [polybar/mpris_module][mpris_module].


## Polybar Support

Polybar mpris bar configurations list in directory [polybar](./polybar).

But it may be not the latest version. Original Polybar configuration files are listed in my project [Unix-like Dotfiles](https://gitlab.com/axdsop/nix-dotfiles/tree/master/Configs/polybar/).

Polybar mpris bar modules configuration lists in [polybar/mpris_module][mpris_module], Iconic font chooses *Nerd Fonts*.

Bar module position for MPRIS moduels

```ini
modules-left = mpris-toggle-mute mpris-track
modules-center = mpris-previous mpris-backward mpris-playpause mpris-forward mpris-next mpris-stop
; mpris-vol-down mpris-vol-up
modules-right = mpris-app-name mpris-reset
```

Bars configuration sample

```ini
[bar/main]
...
...
...

[bar/main_mpris]
inherit = bar/main
bottom = true
enable-ipc = true
include-file = ~/.config/polybar/bar/bar_module_position_mpris
```

**Attention**: To enable [Polybar][polybar] inter-process messaging, bar parameter `enable-ipc` must be set `true`.


## Music Streaming Platform Support

### For Tidal

[Tidal][tidal] doesn't support *nix platform by default.

Here I choose project [Mastermindzh/tidal-hifi](https://github.com/Mastermindzh/tidal-hifi) as client which is a web version of [listen.tidal.com](https://listen.tidal.com) running in electron with hifi support.

The package installation directory is */opt/tidal-hifi*, and config file is *~/.config/tidal-hifi/config.json*.

Its mpris instance is `chromium.instanceXXXXXX` that means you can't use parameter `-p` to specify player name like 'tidal-hifi'.

I add support for *tidal-hifi*, now it works with Polybar (show as `Tidal HiFi`).


### For Spotify

There are many projects about Spotify cli control, e.g. [wandernauta/sp](https://gist.github.com/wandernauta/6800547). Its folk [neerajvashistha/sp](https://gist.github.com/neerajvashistha/a22045093b0d431e903e64e3a98cba5e) added Spotify advertisement prevent from playing.

<!-- Spotify version check

```bash
spotify --version

pidof -s spotify | xargs -i{} bash -c "cat /proc/{}/environ" | sed -r -n '/product-version/{s@.*product-version=[^[:digit:]]+([^[:space:]]+).*@\1\n@g;p}'
``` -->

Script [mpris_player_control][mpris_player_control] doesn't support track position seek (forward/backward) or position set. Spotify official client doesn't support these actions via MPRIS DBus interface. Spotify Web API supports these features, but it needs a Premium account.


#### Advertisement mute

Script [mpris_player_control][mpris_player_control] supports Spotify advertisement track mute for free account.

Video|GitLab|Youtube
---|---|---
Spotify advertisement mute action demo|[demo_spotify_ad_mute.mp4](https://gitlab.com/axdsop/nixnotes/-/blob/image/blob-image/Linux/ArchLinux/i3/mpris_player/demo_spotify_ad_mute.mp4?expanded=true&viewer=rich)|[Youtube](https://www.youtube.com/watch?v=U-uKV0B5QQA)

<!-- <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/U-uKV0B5QQA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe> -->

<!-- [![](https://img.youtube.com/vi/U-uKV0B5QQA/hqdefault.jpg 'mpris-player-control demo - Spotify advertisement mute action')](https://www.youtube.com/watch?v=U-uKV0B5QQA) -->

As I can't get current track position directly from Spotify official client via MPRIS D-bus interface, I can't set how long the sink volume should be muted (also track position seek). So currently if the player is playing advertisements (may be 2 tracks), just click 'next' icon (uf9ab) on Polybar mpris bar. It will keeps muted status until the normal track begin to play.

If possibile, please join Spotify Premium plans.


## Web Browser Support

**Chromium** web browser supports MPRIS by default.

* [Media Keys not working on Ubuntu 17.10](https://askubuntu.com/questions/990284/media-keys-not-working-on-ubuntu-17-10#1011096)

Item|flags
---|---
Hardware Media Key Handling|chrome://flags/#hardware-media-key-handling
MediaSessionService|chrome://flags/#enable-media-session-service


**Mozila Firefox** web browser needs to enable some prefs in `about:config`.

pref|value|note
---|---|---
media.hardwaremediakeys.enabled|true|control media playback, default false
dom.media.mediasession.enabled|true|use Media Session API along with the media control,default false
media.mediacontrol.stopcontrol.timer.ms|86400000|default is 60000 (60s)

See

* [SuperUser - Use MPRIS/dbus media commands within Firefox on Linux](https://superuser.com/questions/1350908/use-mpris-dbus-media-commands-within-firefox-on-linux#1549344)
* [SuperUser - Use Media Keys for Soundcloud, YouTube, etc.. in Firefox?](https://superuser.com/questions/948192/use-media-keys-for-soundcloud-youtube-etc-in-firefox/1547822#1547822)
* [Linux, media keys and multiple players (mpd, chromium, mpv, vlc, …)](https://work.lisk.in/2020/05/06/linux-media-control.html)


## Different with playerctl

Someone asked "How is it different from a script using playerctl?"

>playerctl is a command-line utility and library for controlling media players that implement the MPRIS D-Bus Interface Specification.

Yes, [altdesktop/playerctl][playerctl] is a good solution to control MPRIS-compatible players. But it doesn't support player sink volume control (up/down/mute/unmute) for Spotify official client, and this is the initial reason why I wanna DIY a solution.

To make it works more powerful with Polybar, I add more ane more features. e.g. Polybar mpris bar auto start when detect running MPRIS-compatible player, multi-players selection menu via Rofi, Spotify advertisement mute, notification with corresponding player icon...

And this solution is just for GNU/Linux.

In short, they are designed for different situations.


## Bibliography

* [Automatically pause music on screen lock on Linux](https://saveman71.com/2019/automatic-pause-music-screen-lock-linux-mpris/)
* [Spotify - Basic controls via command line](https://community.spotify.com/t5/Desktop-Linux/Basic-controls-via-command-line/td-p/4295625)
* [Linux, media keys and multiple players (mpd, chromium, mpv, vlc)](https://work.lisk.in/2020/05/06/linux-media-control.html)


## Change Log

* Jun 10, 2020 Wed 15:00 ET
  * first draft
* Jun 16, 2020 Tue 16:36 ET
  * add personal shell script [mpris player control][mpris_player_control]
* Jun 18, 2020 Thu 16:03 ET
  * add Web brower support
* Jul 03, 2020 Fri 15:27 ET
  * Rewrite README
* Jul 03, 2020 Fri 21:45 ET
  * Publish to GitHub
* Jul 04, 2020 Sat 07:53 ET
  * Add overview, script usage sections
* Jul 05, 2020 Sun 10:02 ET
  * Add section *Different with playerctl*, youtube demo video link
* Oct 14, 2020 Wed 16:28 ET
  * Optimize project architecture
* Nov 15, 2020 Sun 10:46 ET
  * Add support for *tidal-hifi*


[mpris_spec]:https://specifications.freedesktop.org/mpris-spec/latest/ "MPRIS D-Bus Interface Specification"
[dbus]:https://www.freedesktop.org/wiki/Software/dbus/ "D-Bus is a message bus system, a simple way for applications to talk to one another."
[playerctl]:https://github.com/altdesktop/playerctl "mpris command-line controller and library for vlc, audacious, bmp, cmus, spotify and others."
[archlinux]:https://www.archlinux.org "A lightweight and flexible Linux distribution"
[i3]:https://i3wm.org/ "i3 - improved tiling wm"
[polybar]:https://polybar.github.io/ "Polybar - A fast and easy-to-use tool for creating status bars"
[tidal]:https://tidal.com "TIDAL - High Fidelity Music Streaming"
[mpris_player_control]:./mpris_player_control
[mpris_module]:../../includes/modules/configs/mpris.ini
[mpris_position]:../../includes/modules/positions/bar_mpris.ini
[polybar_bar_entry]:../../includes/bar_entry.ini

<!-- End -->