#!/vendor/bin/sh

export PATH=/system/bin
FILE_NAME="/asdf/sensor/dumpsys_sensorservice.txt"
FILE_NAME1="/asdf/sensor/dumpsys_sensorservice1.txt"
LINE=`cat $FILE_NAME|wc -l`
	#####echo "$LINE" >> /asdf/sensor/dumpsys_sensorservice.txt
if [ "$LINE" -ge "2000" ]; then
    #####echo "=============BIGGER===========" >> /asdf/sensor/dumpsys_sensorservice.txt
    #sed -i '1,50 d' /asdf/sensor/dumpsys_sensorservice.txt
    rm $FILE_NAME1
    mv $FILE_NAME $FILE_NAME1
fi
	#####echo "`cat /asdf/sensor/dumpsys_sensorservice.txt|wc -l`" >> /asdf/sensor/dumpsys_sensorservice.txt
echo "[`date +%Y/%m/%d` `date +%T`] dumpsys sensorservice" >> $FILE_NAME
dumpsys sensorservice | grep -A50 'active connection' >> $FILE_NAME
