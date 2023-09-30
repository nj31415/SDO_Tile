#! /bin/bash
cd "$(dirname "$0")"

#SDO Website URL
LATEST_URL=https://sdo.gsfc.nasa.gov/assets/img/latest

# DOWNLOAD PATH
LOCALDIR=../IMG_DOWNLOAD

# Channel selection
CHANNELS=( 0094 0131 0171 0193 0211 0304 0335 1600 1700 HMIB HMII HMID HMIBC HMIIF HMIIC )

# Resolution selection (4096, 2048, 1024, 512)
RES_SEL=512

# Set image blend time for FBI command, in ms
B_TIME=500

# Set the backlight brightness
B_LIGHT=50000

# Set the backlight on the Hyperpixel screen
sudo pigpiod
pigs hp 19 100 $B_LIGHT

# ALL CHANNEL DYNAMIC
# Infinite loop to continue grabbing images from SDO database every 15 minutes
while :
do
	for CHANNEL in ${CHANNELS[@]}
	do
		FILENAME="latest_"$RES_SEL"_"$CHANNEL".jpg"
		URL=$LATEST_URL/$FILENAME

		# wget command
		wget -N -nd --no-check-certificate --inet4-only $URL --directory-prefix=$LOCALDIR
	done

	# kill the previous FBI command
	sudo pkill -SIGKILL -t tty2

	sudo fbi -a -T 2 -noverbose -t 30 --blend $B_TIME $LOCALDIR/*
	echo "LOOP COMPLETE"
	sleep 15m
done
