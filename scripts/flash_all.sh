#!/bin/bash
# Flash Droidian for miatoll (Redmi Note 9 Pro / Poco M2 Pro / 9S / Pro Max).
#
# Usage:
#   scripts/flash_all.sh [boot.img dtbo.img vbmeta.img userdata.img]
#
# With no arguments it looks for boot.img, dtbo.img, vbmeta.img and
# userdata.img in the current directory. The phone must be in fastboot
# mode (power off, then hold Volume Down + Power, or: adb reboot bootloader).
#
# WARNING: flashing userdata.img wipes the phone. The script asks for
# confirmation before it touches anything.
set -e

BOOT="${1:-boot.img}"
DTBO="${2:-dtbo.img}"
VBMETA="${3:-vbmeta.img}"
USERDATA="${4:-userdata.img}"

for f in "$BOOT" "$DTBO" "$VBMETA" "$USERDATA"; do
    if [ ! -f "$f" ]; then
        echo "missing image: $f" >&2
        echo "usage: $0 [boot.img dtbo.img vbmeta.img userdata.img]" >&2
        exit 1
    fi
done

if ! fastboot devices | grep -q .; then
    echo "no device in fastboot mode found." >&2
    echo "reboot the phone into fastboot (Volume Down + Power) and retry." >&2
    exit 1
fi

echo "This will flash Droidian and WIPE the phone (userdata)."
read -r -p "Type YES to continue: " confirm
if [ "$confirm" != "YES" ]; then
    echo "aborted."
    exit 1
fi

fastboot flash boot "$BOOT"
fastboot flash dtbo "$DTBO"
fastboot flash vbmeta "$VBMETA"
fastboot flash userdata "$USERDATA"
fastboot reboot
echo "done — the phone is rebooting into Droidian."
