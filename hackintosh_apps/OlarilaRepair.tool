#!/bin/bash

function msg {
	printf "\e[1;32m>>>>>>\e[m %s\n" "$1"
}
function msg2 {
	printf "\e[1;34m>>>>>>\e[m %s\n" "$1"
}

msg "Olarila.com - All About Vanilla Hackintosh"

sudo spctl --master-disable
osascript <<EOT
tell application "Finder"
 activate
 display alert "Check OLARILA.COM for Professional Hackintosh support!"
end tell
EOT
sudo spctl --global-disable
sudo defaults write /var/db/SystemPolicyConfiguration/SystemPolicy-prefs.plist enabled -string no
sudo kextcache -i /
/usr/bin/kmutil install --volume-root /
sudo nvram -c
sudo pmset autopoweroff 0
sudo pmset powernap 0
sudo pmset standby 0
sudo pmset proximitywake 0
sudo pmset tcpkeepalive 0
sudo pmset -a hibernatemode 0
sudo rm -f /private/var/vm/sleepimage
sudo touch /private/var/vm/sleepimage
sudo touch /Library/Extensions
sudo touch /System/Library/Extensions
sudo chflags uchg /private/var/vm/sleepimage
ls -la /private/var/vm

msg "Completed!"
osascript -e 'tell app "loginwindow" to «event aevtrrst»'