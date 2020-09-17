#!/system/bin/sh

# stop battery safety upgrade
echo 3 >  /proc/Batt_Cycle_Count/batt_safety_csc

# delete battery safety & health data
rm /batinfo/.bs
rm /batinfo/.bh
rm /batinfo/Batpercentage
rm /batinfo/bat_health
rm /batinfo/bat_safety

# initial battery safety data
echo 0 >  /proc/Batt_Cycle_Count/batt_safety_csc

# reload battery safety data
echo 9 >  /proc/Batt_Cycle_Count/batt_safety_csc

# start battery safety upgrade
echo 4 >  /proc/Batt_Cycle_Count/batt_safety_csc
