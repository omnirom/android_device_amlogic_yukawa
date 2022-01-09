First time flash instructions - for normal OTA see below
LINUX ONLY - most steps are also possible on windows except flashing u-boot
if you know how to do this on windows - be happy but dont ask me for support

VIM3 PRO ONLY - u-boot partition layout is for 32GB only
Download location https://dl.omnirom.org/tmp/yukawa/
Android device name for the VIM3 is yukawa

Requirements:
-latest android platform tools for fastboot (you MUST have a fastboot that supports the wipe-super command)
https://developer.android.com/studio/releases/platform-tools

-payload_dumper to extract images from OTA zip payload.bin
https://github.com/vm03/payload_dumper

-amlogic USB boot utility
From https://dl.omnirom.org/tmp/yukawa/setup/update or
https://github.com/omnirom/android_device_amlogic_yukawa/tree/android-12.0/bootloader/tools/update

-custom u-boot
From https://dl.omnirom.org/tmp/yukawa/setup/u-boot_kvim3pro_ab.bin or
https://github.com/omnirom/android_device_amlogic_yukawa/tree/android-12.0/bootloader/u-boot_kvim3pro_ab.bin

-super-empty.img file
From https://dl.omnirom.org/tmp/yukawa/setup/super-empty.img

-USB keyboard connected to device needed to navigate in fastbootd and recovery

Steps:

Download latest OTA zip
-----------------------

From https://dl.omnirom.org/tmp/yukawa/

Naming conventions for OTA zip file

omni-<version>-<date>-yukawa-<type>.zip
type can be GAPPS|MICROG|WEEKLY

eg omni-12-20211125-yukawa-MICROG.zip

Optional download matching md5sum file and verify integrity of your download

Extract images from OTA zip with payload_dumper
-----------------------------------------------

You can read more at eg https://www.thecustomdroid.com/how-to-extract-android-payload-bin-file/

1) extract payload.bin file from OTA zip

2) run payload_dumper.py to extract images from payload.bin
python payload_dumper.py payload.bin

When finished you will have these 5 image files in subdir output:
boot.img
dtbo.img
system.img
vendor.img
vbmeta.img

Flash custom u-boot
--------------------

see also https://gitlab.com/baylibre/amlogic/atv/aosp/device/amlogic/yukawa/-/wikis/Khadas_VIM3#flash-android-bootloader

update write u-boot_kvim3pro_ab.bin 0xfffa0000 0x10000
update run 0xfffa0000
update bl2_boot u-boot_kvim3pro_ab.bin

device will reboot into bootloader fastboot mode

fastboot oem format
fastboot flash bootloader u-boot_kvim3pro_ab.bin
fastboot erase bootenv
fastboot reboot bootloader

unplug and plug power cable or use reset button - device will reboot into fastboot again

Flash images
------------

1) flash normal partitions

fastboot flash boot boot.img 
fastboot flash vbmeta vbmeta.img 
fastboot flash dtbo dtbo.img

(optional for both slots - default will be slot a (eg boot_a) slot b will be used on next OTA)

fastboot reboot fastboot

device will reboot and enter fastbootd

This has a text based UI that you can navigate with keyboard
but we continue on terminal

2) create virtual partitions layout 
fastboot wipe-super super_empty.img 

3) flash virtual partitions
fastboot flash system_a system.img 
fastboot flash vendor_a vendor.img
(optional also for slot _b)

4) format userdata partition

method 1:
fastboot format userdata

method 2:
fastboot reboot recovery (or "Enter recovery" from menu)

Device will change into recovery mode (no more fastboot mode but you can use adb)
and select "Wipe data/factory reset"

5) Reboot
"Reboot system now"

Device will boot into Android

Normal OTA update process:

Way easier :)

2 different possible ways
#1 using OTA app -> recommended
This will check for updates and notifies if available
It will download the update and apply the update
After that just press reboot button and done

#2 using recovery with adb sideload
Download OTA zip manually to your PC
Reboot into recovery either from power button menu or from shell with
adb reboot recovery

Select "Apply update from adb" and follow the instructions
adb sideload <OTA zip file>
