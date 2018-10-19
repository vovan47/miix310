# General
This repo will contain useful information and code snippets about Linux (Ubuntu 18) on Lenovo MIIX 310-10 ICR tablet.
Device specs: https://www.lenovo.com/us/en/tablets/windows-tablets/miix-series/Ideapad-Miix-310/p/88EMMX30692
It is not available anymore, but they released a MIIX-320 which is pretty much the same, maybe a bit better.
Device has Intel Atom X5 Z8350 Processor. Touchscreen model is "Goodix Capacitive TouchScreen". Audio is rt5645. Video: Intel CherryTrail.
Further information could be useful on similar platforms.

# Updating BIOS

If you want to install Linux, you have to update BIOS to latest version (1HCN44WW at the moment of writing this) from Windows installation.
Download it here: https://pcsupport.lenovo.com/gb/en/products/tablets/miix-series/miix-310-10icr/downloads/ds112922
Installation is straightforward.

# Ubuntu installation

It is pretty much standart - as easy as just booting from USB and installing OS. 
But after first boot you will see a "black" screen - it's not really black, but backlight brightness is on zero level for some reason.
For the first time it could be "fixed" by closing and reopening the lid. Also pushing "power" button might gelp.
This is annoying, so we will fix it in the next section.

# Fixing quirks & other improvements

## Screen orientation on first boot

It could be that screen is rotated in a horizontal way at first boot.
To rotate it properly:
1. Open a terminal with Ctrl + Alt + T
1. Type `xrandr -o right` and hit enter.
If that persists, just add put line to auto-load.

## Fixing black screen on boot.
Credits are going to this post on Lenovo forum: https://forums.lenovo.com/t5/Linux-Discussion/ubuntu-for-Miix-310-10ICR-Tablet/m-p/3996259/highlight/true#M10556

Copy-paste:
1. Add "pwm_lpss_platform" into `/etc/initramfs-tools/modules` file
1. `$ sudo update-initramfs -k all -u`

## GRUB tweaks

1. Edit GRUB_CMDLINE_LINUX_DEFAULT in `/etc/default/grub`
1. Make it look like this: `GRUB_CMDLINE_LINUX_DEFAULT="video=DSI-1:800x1280e acpi_osi= i915.modeset=1 fbcon=rotate:1  video.use_native_backlight=1 i915.enable_fbc=1 i915.enable_rc6=1 i915.semaphores=1 nospalsh quiet"`
1. `$ sudo update-grub`

## Backlight

After all above tweaks, native backlight regulation still doesn't work, at least for me.
In theory, it is fixed in new version of Linux kernel: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1783964
But I've tried recompiling kernel with those options enabled and it still doesn't work.
So I use `xrandr` to change brightness via terminal. I wrote a small Bash script to simplify usage, I will put it here in separate file, `brightness.sh`.


