#!/vendor/bin/sh

setprop vendor.sys.asus.setenforce 1
echo "[check key status] setenforce: permissive" > /proc/asusevtlog
sleep 5

/vendor/bin/is_keybox_valid
/vendor/bin/is_keymaster_valid
/vendor/bin/is_hdcp_valid

ret=$(/vendor/bin/hdcp2p2prov -verify)
if [ "${ret}" = "Verification succeeded. Device is provisioned." ]; then
	setprop "vendor.atd.hdcp2p2.ready" TRUE
else
	setprop "vendor.atd.hdcp2p2.ready" FALSE
fi

ret=$(/vendor/bin/hdcp1prov -verify)
if [ "${ret}" = "Verification succeeded. Device is provisioned." ]; then
	setprop "vendor.atd.hdcp1.ready" TRUE
else
	setprop "vendor.atd.hdcp1.ready" FALSE
fi

/vendor/bin/ifaa_product 2
/vendor/bin/vendor.qti.hardware.soter@1.0-provision 2

setprop vendor.sys.asus.setenforce 0
echo "[check key status] setenforce: enforcing" > /proc/asusevtlog
