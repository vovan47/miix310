# General
This repo contains useful information and code snippets about Linux installation (Ubuntu 18) on Lenovo MIIX 310-10 ICR tablet.
[Device specs are here.](https://www.lenovo.com/us/en/tablets/windows-tablets/miix-series/Ideapad-Miix-310/p/88EMMX30692)
It is not available anymore, but they released a MIIX-320 which is pretty much the same, maybe a bit better.
Device has Intel Atom X5 Z8350 Processor [More on WikiChip](https://en.wikichip.org/wiki/intel/atom_x5/x5-z8350). Touchscreen model is "Goodix Capacitive TouchScreen". Audio is rt5645. Video: Intel CherryTrail. I have 2GB of RAM, but there were versions with 4GB.
Further information could be useful on similar platforms.

# Updating BIOS

If you want to install Linux, you have to update BIOS to latest version (1HCN44WW at the moment of writing this) from Windows installation.
Download it [here (Lenovo official)](https://pcsupport.lenovo.com/gb/en/products/tablets/miix-series/miix-310-10icr/downloads/ds112922).
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
If that persists, just add the above line to auto-load.

## Fixing black screen on boot
Credits are going to [this post on Lenovo forum](https://forums.lenovo.com/t5/Linux-Discussion/ubuntu-for-Miix-310-10ICR-Tablet/m-p/3996259/highlight/true#M10556).

1. Add "pwm_lpss_platform" into `/etc/initramfs-tools/modules` file
1. `$ sudo update-initramfs -k all -u`

## GRUB tweaks

1. Edit GRUB_CMDLINE_LINUX_DEFAULT in `/etc/default/grub`
1. Make it look like this: `GRUB_CMDLINE_LINUX_DEFAULT="video=DSI-1:800x1280e acpi_osi= i915.modeset=1 fbcon=rotate:1  video.use_native_backlight=1 i915.enable_fbc=1 i915.enable_rc6=1 i915.semaphores=1 nosplash quiet"`
1. `$ sudo update-grub`

## Backlight

After all above tweaks, native backlight regulation still doesn't work, at least for me.
In theory, it is [fixed in new version of Linux kernel.](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1783964)
But I've tried recompiling kernel with those options enabled and it still doesn't work.
So I use `xrandr` to change brightness via terminal. I wrote a small Bash script to simplify usage, I will put it here in separate file, `brightness.sh`.

## Improving sound

I heard a lot of complaints about low sound volume on this device on all OS and had it personally on Windows.
But it turned out that it's not hardware problem!
On linux it could be fixed with special config files called "UCM for ALSA".
Here is the repo you should use: 
https://github.com/plbossart/UCM
Just download the archive.
For this device, audio is "rt5645" which corresponds to "chtrt5645" from that repo.
Copy this folder to `/usr/share/alsa/ucm/`:
`# cp -r ~/Downloads/UCM/chtrt5645 /usr/share/alsa/ucm/`
Reboot and sound should be loud.

# Recompiling the kernel

The device is pretty low-perfomance, so, to make most out of it, you might want to re-compile kernel with specific settings for that platform.
So here are instructions how it's done in Ubuntu.

1. Download latest stable kernel from https://www.kernel.org
1. Install required packages:
`$ sudo apt-get install gcc make libncurses5-dev libssl-dev bison flex libelf-dev`
1. You need to apply [this patch](https://github.com/graysky2/kernel_gcc_patch) to have extra processor type options that we need
To do that, just download it, put into folder where you extracted downloaded archive and execute `$ patch -p1 < PATCH_NAME.patch`
1. Run configuration program `$ make menuconfig` 
1. Under "Processor type and features -> Processor family" select "Intel Silvermont family of low-power Atom processors (Silvermont)"
1. You can do some extra edits to configuration if you know what you are doing. For example, I've set `CONFIG_DEBUG_INFO` to `n`.
1. When you are done, save the config and exit.
1. `$ make localmodconfig`. All devices that are going to be used should be plugged into device on this point. You can just press "Enter" or "Yes" to all questions.
1. Compile it with `$ make -j4 bindeb-pkg` command. "4" after `-j` is a number of threads (or logical processors in your system).
1. Wait 20-30 minutes until it's done. `.deb` files will appear in a directory one level above. Install them with `$ sudo dpkg -i linux*.deb` command.
1. If everything is correct, Ubuntu will boot into a new kernel after reboot. If something gone wrong, access GRUB boot menu and select older kernel version.

## Docker support

Yes, this processor has virtualization feature and can run Docker!
However, if you recompiled kernel with instructions above, some required parameters will be not set. 
Here is a bash script to check your kernel config: [link](https://github.com/moby/moby/blob/master/contrib/check-config.sh)
I spent some time searching for desired options and finding them in the `menuconfig`. (no, you can't just enable them in a text file, as they have dependencies).
I will put my `.config` here as a separate file.
If you will use my config *please note that it's for `4.18.13`* kernel version. To use the configuration of the old kernel with the new kernel, it needs to be converted. The conversion can be done by running either `make silentoldconfig` or `make olddefconfig`. Use either, not both.

# That's it. Cheers!
