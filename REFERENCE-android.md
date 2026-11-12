# What is in the android image

`x86_64`, the `kvm` image plus the Android SDK in `/opt/android-sdk` (`ANDROID_HOME`). Written by the build from the image.

| Part | Version |
| --- | --- |
| Command-line tools | 13114758 (`sdkmanager`, `avdmanager`) |
| Platform tools | `adb` (latest at build) |
| Emulator | latest at build |
| System image | `system-images;android-34;google_apis;x86_64` |
| Java | OpenJDK 21 (headless) |

`adb`, `emulator`, `sdkmanager` and `avdmanager` are in `/usr/local/bin`. The emulator needs `/dev/kvm`. Google's Android SDK licence was accepted at build time.

## Image

`ghcr.io/briq-cloud/sandbox:android`. The Dockerfile: [Dockerfile.android](Dockerfile.android).
