#!/bin/bash
# Build the adaptation .deb files locally.
#
# Upstream CI generates debian/changelog; this repo has none, so the
# script creates a temporary one, builds with dpkg-buildpackage, then
# removes it again, leaving the tree clean. Needs: debhelper, dpkg-dev.
# The .deb files land in the parent directory.
set -e
cd "$(dirname "$0")/.."

if ! command -v dpkg-buildpackage >/dev/null; then
    echo "dpkg-buildpackage not found — install debhelper first:" >&2
    echo "  sudo apt-get install debhelper dpkg-dev" >&2
    exit 1
fi

VERSION="1.0~git$(date +%Y%m%d).$(git rev-parse --short HEAD 2>/dev/null || echo nogit)"
cat > debian/changelog <<EOF
adaptation-xiaomi-miatoll ($VERSION) unstable; urgency=medium

  * Local build.

 -- Droidian Miatoll <droidian-miatoll@example.invalid>  $(date -R)
EOF

cleanup() {
    rm -f debian/changelog
    rm -rf debian/.debhelper debian/*.substvars debian/*.debhelper.log \
        debian/*.postinst.debhelper debian/*.postrm.debhelper \
        debian/adaptation-miatoll-android debian/adaptation-miatoll-configs \
        debian/adaptation-xiaomi-miatoll debian/debhelper-build-stamp debian/files
}
trap cleanup EXIT

dpkg-buildpackage -us -uc -b
echo "built:"
ls ../adaptation-*.deb
