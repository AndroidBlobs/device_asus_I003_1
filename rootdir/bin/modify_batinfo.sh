#! /vendor/bin/sh

echo "CY. try to run chown" > /proc/asusevtlog
chown -R shell:root /batinfo
chmod -R 0775 /batinfo
echo "CY. try to run chmod" > /proc/asusevtlog

