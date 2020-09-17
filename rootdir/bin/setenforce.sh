#!/vendor/bin/sh

echo 1 > /sys/fs/selinux/log
sleep 3

# check boot complete
android_boot=`getprop sys.boot_completed`
if [ "$android_boot" == "" ] || ["$android_boot" == "0"]; then
	echo "boot not ready !!"
	exit
fi

setenforce_prop=`getprop vendor.asus.setenforce`
if [ "$setenforce_prop" == "" ]; then
	exit
fi

if [ "$setenforce_prop" == "1" ]; then
	echo asussetenforce:0 > /proc/rd
else
	echo asussetenforce:1 > /proc/rd
fi
echo "Set vendor.asus.setenforce:$setenforce_prop to setenforce"

startlog_flag=`getprop persist.vendor.asus.startlog`
if test "$startlog_flag" -eq 0; then
	echo 0 > /sys/fs/selinux/log
else
	echo 1 > /sys/fs/selinux/log
fi
