#!/bin/bash
set -e
# By SkylineIsBack

clear
echo "
   ____   _____ _____   _____ 
  / __ \ / ____|  __ \ / ____|
 | |  | | (___ | |__) | |     
 | |  | |\___ \|  ___/| |     
 | |__| |____) | |    | |____ 
  \___\_\_____/|_|     \_____|
                              "
echo ""
read -p "Number of columns in the QuickSettings: " columns
read -p "Number of rows in the QuickSettings: " rows
read -p "Number of tiles in the QuickQSPanel: " tiles
read -p "Number of rows in the QuickQSPanel: " qqsrows
defaultlocation="$(dirname $(readlink -f $0))"
name=qspanel"$columns"x"$rows"x"$tiles"
cd $defaultlocation/input
mkdir "$name"
cd "$name"
touch AndroidManifest.xml
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"
  package=\"com.android.$name\"
  android:versionCode=\"1\"
  android:versionName=\"1.0\">
  <overlay android:targetPackage=\"com.android.systemui\"
    android:priority=\"1\"
    android:isStatic=\"true\" />
</manifest>" >> AndroidManifest.xml
touch Android.mk
echo 'LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional' >> Android.mk
echo "LOCAL_PACKAGE_NAME := overlay-$name" >> Android.mk
echo 'LOCAL_IS_RUNTIME_RESOURCE_OVERLAY := true
LOCAL_PRIVATE_PLATFORM_APIS := true
include $(BUILD_PACKAGE)' >> Android.mk
mkdir res
cd res
mkdir values
cd values
touch config.xml
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<resources>
    <integer name=\"quick_qs_panel_max_tiles\">$tiles</integer>
    <integer name=\"quick_qs_panel_max_rows\">$qqsrows</integer>
    <integer name=\"quick_settings_num_columns\">$columns</integer>
    <integer name=\"quick_settings_max_rows\">$rows</integer>
</resources>" >> config.xml
cd $defaultlocation
export LD_LIBRARY_PATH=.
aapt package -f -F "${name}-overlay.apk" -M "$defaultlocation/input/$name/AndroidManifest.xml" -S "$defaultlocation/input/$name/res" -I $defaultlocation/android.jar
java -jar apksigner.jar sign --key $defaultlocation/keys/releasekey.pk8 --cert $defaultlocation/keys/releasekey.x509.pem "${name}-overlay.apk"
cp -r "${name}-overlay.apk" backup/
mv "${name}-overlay.apk" output/
rm -rf input/"$name"
rm -rf "${name}-overlay.apk.idsig"
echo ""
echo 'Do you want to copy this overlay to /vendor/overlay ? (y/n)'
read whattodo
if [[ $whattodo = "y" ]]
then
    su -c mount -o rw,remount /vendor
    su -c mv output/"${name}-overlay.apk" /vendor/overlay/
    su -c chmod 644 /vendor/overlay/"${name}-overlay.apk"
    echo ""
    echo "Copied successfully"
    echo ""
    echo "Do you want to reboot the device? (y/n)"
    read rebootdevice
    if [[ "$rebootdevice" = "y" ]]
    then
        su -c reboot
    else
        echo "Exiting"
        exit
    fi
else
    rm -rf output/"${name}-overlay.apk"
    echo "The compiled overlay is present in QSPC/backup folder."
    echo "Exiting"
    exit
fi
