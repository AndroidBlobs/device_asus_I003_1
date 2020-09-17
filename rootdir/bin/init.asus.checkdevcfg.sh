#!/system/vendor/bin/sh

# Set Selinux
echo 1 > /sys/fs/selinux/log
sleep 1

android_boot=`getprop sys.boot_completed`
downloadmode=`getprop persist.vendor.sys.downloadmode.enable`
platform=`getprop ro.build.product`
unlocked=`getprop vendor.atd.unlocked.ready`
stage=`getprop ro.boot.id.stage`
imei1=`getprop persist.vendor.radio.device.imei`
imei2=`getprop persist.vendor.radio.device.imei2`

# ZS661KS Q
echo "ro.build.product = $platform"
if [ "$platform" != "ZS661KS" ]; then
	echo "It is not ZS661KS !!"
	exit
fi

# check boot complete
timeout=0
while [ "$android_boot" -ne "1" ]; do
	timeout=$(($timeout+1))
	if [ $timeout == 300 ]; then
		echo "[Debug] check boot complete timeout exit ($timeout)!!" > /proc/asusevtlog
		exit
	fi
	echo "boot not ready !!"
	sleep 1
	android_boot=`getprop sys.boot_completed`
done
echo "[Debug] boot ready ($android_boot)!!"

# Check MP
if [ "$stage" == "7" ]; then
	# Check IMEI
	imei_result1=`grep -c "$imei1" /vendor/etc/IMEI_whitelist.txt`
	echo "[Debug] check imei1 : $imei_result1"
	imei_result2=`grep -c "$imei2" /vendor/etc/IMEI_whitelist.txt`
	echo "[Debug] check imei2 : $imei_result2"
	if [ "$imei_result1" == "1" ] || [ "$imei_result2" == "1" ]; then
		echo "[Debug] whitelist imei found !!" > /proc/asusevtlog
	else
		# RSASD 
		# wait 1 sec to get /sdcard/dat.bin
		sync
		sleep 1
		sync
		myShellVar=`(rsasd)`
		sleep 1
		sync
		#myShellVar=`$(rsasd)`
		echo "[Debug] myShellVar = ($myShellVar)!!"
		echo "[Debug] whitelist imei not found!!"
		if [ "$myShellVar" == "13168" ]; then
			echo "[Debug] check rsasd : pass" > /proc/asusevtlog
		else
			echo "[Debug] check rsasd : fail" > /proc/asusevtlog
			exit
		fi
	fi
fi

# check downloadmode flag & devcfg
devcfg_diff=0
if [ "$downloadmode" == "1" ]; then
	mkdir -p /asdf/devcfg
	dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/asdf/devcfg/devcfg_system.mbn bs=1024 count=47
	dd if=/dev/block/sde14 of=/asdf/devcfg/devcfg_check_a.mbn bs=1024 count=47
	dd if=/dev/block/sde37 of=/asdf/devcfg/devcfg_check_b.mbn bs=1024 count=47
	devcfgcheck_a=`md5sum -b /asdf/devcfg/devcfg_check_a.mbn`
	devcfgcheck_b=`md5sum -b /asdf/devcfg/devcfg_check_b.mbn`
	devcfgsystem=`md5sum -b /asdf/devcfg/devcfg_system.mbn`
	echo "[Debug] devcfgcheck_a : $devcfgcheck_a"
	echo "[Debug] devcfgcheck_b : $devcfgcheck_b"
	echo "[Debug] devcfgsystem : $devcfgsystem"
	if [ "$devcfgcheck_a" != "$devcfgsystem" ] || [ "$devcfgcheck_b" != "$devcfgsystem" ]; then
		devcfg_diff=1
	fi
fi
echo "[Debug] devcfg_diff: $devcfg_diff"

# Update devcfg
success=0
if [ "$devcfg_diff" == "1" ]; then
	dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde14
	dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde37
	sync
	# Check
	dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/asdf/devcfg/devcfg_system.mbn bs=1024 count=47
	dd if=/dev/block/sde14 of=/asdf/devcfg/devcfg_check_a.mbn bs=1024 count=47
	dd if=/dev/block/sde37 of=/asdf/devcfg/devcfg_check_b.mbn bs=1024 count=47
	devcfgcheck_a=`md5sum -b /asdf/devcfg/devcfg_check_a.mbn`
	devcfgcheck_b=`md5sum -b /asdf/devcfg/devcfg_check_b.mbn`
	devcfgsystem=`md5sum -b /asdf/devcfg/devcfg_system.mbn`
	echo "[Debug] devcfgcheck_a : $devcfgcheck_a"
	echo "[Debug] devcfgcheck_b : $devcfgcheck_b"
	echo "[Debug] devcfgsystem : $devcfgsystem"
	if [ "$devcfgcheck_a" != "$devcfgsystem" ] || [ "$devcfgcheck_b" != "$devcfgsystem" ]; then
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde14
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/dev/block/sde37
		sync
		# check again
		dd if=/system/vendor/etc/devcfg_tzOn.mbn of=/asdf/devcfg/devcfg_system.mbn bs=1024 count=47
		dd if=/dev/block/sde14 of=/asdf/devcfg/devcfg_check_a.mbn bs=1024 count=47
		dd if=/dev/block/sde37 of=/asdf/devcfg/devcfg_check_b.mbn bs=1024 count=47
		devcfgcheck_a=`md5sum -b /asdf/devcfg/devcfg_check_a.mbn`
		devcfgcheck_b=`md5sum -b /asdf/devcfg/devcfg_check_b.mbn`
		devcfgsystem=`md5sum -b /asdf/devcfg/devcfg_system.mbn`
		echo "[Debug] devcfgcheck_a : $devcfgcheck_a"
		echo "[Debug] devcfgcheck_b : $devcfgcheck_b"
		echo "[Debug] devcfgsystem : $devcfgsystem"
		if [ "$devcfgcheck_a" == "$devcfgsystem" ] && [ "$devcfgcheck_b" == "$devcfgsystem" ]; then
			success=1
		fi
	else
		success=1
	fi
fi
echo "[Debug] success: $success"

# Remove binary
if [ -e /asdf/devcfg/ ]; then
	rm -rf /asdf/devcfg/
	echo "[Debug] Remove devcfg"
fi
setprop persist.vendor.asus.checkdevcfg 0

# Reboot
if [ "$devcfg_diff" == "1" ]; then
	echo "[Reboot] Enable DLmode & Load devcfg ($platform:$success)" > /proc/asusevtlog
	sleep 1
	/system/bin/reboot update_devcfg
fi

# Set selinux
startlog_flag=`getprop persist.vendor.asus.startlog`
if [ "$startlog_flag" == "0" ] && [ "$downloadmode" == "0" ]; then
	echo 0 > /sys/fs/selinux/log
else
	echo 1 > /sys/fs/selinux/log
fi
