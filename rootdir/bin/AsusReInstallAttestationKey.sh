#!/vendor/bin/sh

LOG_TAG="REWORK_COUNTRY"

COUNTRY=""
NEW_COUNTRY=""
IMEI1=""
HK_DEVICE=""

logi ()
{
	/vendor/bin/log -t $LOG_TAG -p i "$@"
}

set_country ()
{
	COUNTRY=`cat mnt/vendor/persist/COUNTRY`
	#IMEI1=`getprop persist.vendor.radio.device.imei`
	IMEI1=`cat mnt/vendor/persist/IMEI`

	if [  -z "$IMEI1" ] ;then
		logi "CANNOT GET IMEI1, just exit!"
		exit
	fi

	HK_DEVICE=`cat vendor/bin/HK-202008.csv | grep $IMEI1`

	logi "COUNTRY = $COUNTRY"
	logi "IMEI1 = $IMEI1"
	logi "HK_DEVICE = $HK_DEVICE"

	if [ "$COUNTRY" != "HK" ] && [ ! -z "$HK_DEVICE" ] ;then

		logi "need to rewrite."
		# write HK to COUNTRY
		echo -n "HK" > mnt/vendor/persist/COUNTRY

		chmod 666 mnt/vendor/persist/COUNTRY
		chown shell:shell mnt/vendor/persist/COUNTRY

		NEW_COUNTRY=`cat mnt/vendor/persist/COUNTRY`

		setprop vendor.x-rr.vendor.config.versatility $NEW_COUNTRY
		#serial_client -c at+cnvm=3,8013,484B0000
    
        echo "at+cnvm=3,8013,484B0000\r" > /dev/mhi_0306_02.01.00_pipe_32
        #cat /dev/mhi_0306_02.01.00_pipe_32

		logi "NEW_COUNTRY = $NEW_COUNTRY, rewrite done."

	else
		logi "do nothing."
	fi

}

setprop vendor.sys.asus.setenforce 1
echo "[Re-install AttKey] setenforce: permissive" > /proc/asusevtlog
sleep 5

set_country

/vendor/bin/install_key_server decrypt
sleep 1
setprop vendor.sys.asus.setenforce 0
echo "[Re-install AttKey] setenforce: enforcing" > /proc/asusevtlog
