#!/bin/sh
# What the android image has, without /dev/kvm.
set -eu
sdkmanager --list_installed | grep -E 'platform-tools|emulator|system-images;android-34;google_apis;x86_64' | wc -l | grep -qx 3
emulator -version | head -n 3
adb version | head -n 1
avdmanager list target > /dev/null
java -version
