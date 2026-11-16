# Droidian for Xiaomi Redmi Note 9 Pro / miatoll

Droidian adaptation for the **Xiaomi Redmi Note 9 Pro (Global)** and the
rest of the miatoll family (Poco M2 Pro, Redmi Note 9 Pro Max, Redmi Note 9S).

This is a fork of
[droidian-devices/adaptation-droidian-miatoll](https://github.com/droidian-devices/adaptation-droidian-miatoll)
with one fix applied: **dual SIM now works**.

- Device codename: `miatoll` (joyeuse = Redmi Note 9 Pro Global, model M2003J6B2G)
- Halium 10 / Android 10 vendor (API 29), Linux kernel 4.14
- Droidian 101, Phosh

## The dual-SIM fix

Upstream, only the first SIM was ever detected. The cause was not a wrong
number — the second slot was never configured at all:

- The base ofono config (`ofono-configs-binder-common`,
  `/etc/ofono/binder.conf`) defines only
  `[slot1] path=/ril_0 slot=0`.
- The `[slot2] path=/ril_1 slot=1` definition lives in the separate
  package `ofono-configs-binder-dual-sim`, which the adaptation never
  installed, because it depended on `adaptation-hybris-api29-phone`
  (single-SIM) instead of `adaptation-hybris-api29-phone-dual-sim`.
- ofono drops any slot with no `path` in its config, so only one modem
  (`/ril_0`) was ever created.

The fix, in `debian/control`:

```diff
-         adaptation-hybris-api29-phone,
+         adaptation-hybris-api29-phone-dual-sim,
```

After installing the fixed package, ofono creates both modems
(`/ril_0` and `/ril_1`) and both SIMs appear.

> Status: the fix is verified at packaging level (the built metapackage
> pulls in the dual-SIM config). The on-device test is still pending —
> please report back whether both SIMs show up after flashing.

## What works / what doesn't

From the [official device page](https://devices.droidian.org/#/devices/miatoll):

- Works: camera (photo/video/switch/flashlight), sound, sensors
  including fingerprint, WiFi/hotspot, NFC, Bluetooth, calls, mobile
  data, SMS, SD card, Waydroid, MTP, GPS.
- Fixed here: **dual SIM**.
- Still not working: MMS, system encryption (disabled).
- Default passcode: `1234`.

## Prerequisites

- A miatoll device: Redmi Note 9 Pro Global (joyeuse) is the tested
  one; Poco M2 Pro / Note 9 Pro Max / Note 9S share the same build.
- Stock **Android 10** firmware: MIUI **12.0.2** for the Global Note 9
  Pro (other miatoll variants: 12.0.3). Downgrade first if you are on
  a newer version — Droidian needs the Android 10 vendor.
- **Unlocked bootloader** (Mi Unlock; this wipes the phone, back up
  first). Save your APN settings before wiping.
- A Linux PC with `adb` and `fastboot`, and a USB cable.
- Do **not** use the Redmi Note 9 Pro 5G (gauguin) — different device,
  not supported by this port.

## Install

### Option A — flash the official image, then install the fix (easiest)

1. Flash the official Droidian 101 image for miatoll with the
   [Droidian Installer](https://droidian.org/) (or `flash_all.sh` from
   the image — see below) and boot once.
2. Get the fixed adaptation package, either:
   - download the `.deb` from the **Actions** tab of this repo
     (the `build` workflow builds it on every push), or
   - build it yourself: `scripts/build-deb.sh` (needs `debhelper`).
3. Copy `adaptation-xiaomi-miatoll_*.deb` to the phone and install it:
   ```sh
   sudo dpkg -i adaptation-xiaomi-miatoll_*.deb
   sudo apt-get install -f
   sudo reboot
   ```
4. After reboot, open **Settings → Mobile network** — both SIMs should
   be listed. From a terminal you can also check:
   ```sh
   gdbus call --system --dest org.ofono --object-path / \
     --method org.ofono.Manager.GetModems
   ```
   It should list both `/ril_0` and `/ril_1`.

### Option B — build the full image with this adaptation

Follow the [Droidian porting guide](https://github.com/droidian/porting-guide):
build the kernel (`linux-android-xiaomi-miatoll`, branch `droidian`)
and this adaptation package, then generate the device image with
`droidian-images`:

```sh
./generate_device_recipe.py xiaomi_miatoll arm64 phosh phone 29
debos --disable-fakemachine generated/droidian.yaml
```

Then flash the resulting `boot.img`, `dtbo.img`, `vbmeta.img` and
`userdata.img` with the script in this repo (see below). If you build
the image from the official archive first, install the fixed `.deb`
after first boot as in Option A.

### Flashing the images manually

`scripts/flash_all.sh` flashes the four images over fastboot:

```sh
cd /path/to/image-dir
/path/to/repo/scripts/flash_all.sh
```

It checks that a device is connected in fastboot mode, flashes
`boot.img`, `dtbo.img`, `vbmeta.img` and `userdata.img`, then reboots.
**Flashing `userdata.img` wipes the phone** — the script asks for
confirmation first. You can also pass the images as arguments:

```sh
scripts/flash_all.sh boot.img dtbo.img vbmeta.img userdata.img
```

## Build the adaptation package locally

```sh
scripts/build-deb.sh
```

This generates a temporary `debian/changelog` (upstream CI generates
the real one), builds the three `.deb` files with `dpkg-buildpackage`,
and removes the changelog again, leaving only the fix in the tree.
The `.deb` files land in the parent directory.

## Contributing

Found something? The upstream project lives at
[droidian-devices/adaptation-droidian-miatoll](https://github.com/droidian-devices/adaptation-droidian-miatoll).
Fixes that belong upstream should be sent there as a pull request;
this repo tracks upstream plus the dual-SIM fix.

## Links

- Official device page: https://devices.droidian.org/#/devices/miatoll
- Droidian porting guide: https://github.com/droidian/porting-guide
- Kernel: https://github.com/droidian-devices/linux-android-xiaomi-miatoll
- Upstream adaptation: https://github.com/droidian-devices/adaptation-droidian-miatoll
- ofono binder config: https://github.com/droidian/ofono-config-ril-binder
- Ubuntu Touch port (same hardware family): https://devices.ubuntu-touch.io/device/joyeuse
