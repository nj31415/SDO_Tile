#! /bin/bash
cd "$(dirname "$0")"

# Set the backlight on the Hyperpixel screen
sudo pigpiod
pigs hp 19 100 50000

#SDO Website URL
LATEST_URL=https://sdo.gsfc.nasa.gov/assets/img/latest

# DOWNLOAD PATH
LOCALDIR=../IMG_DOWNLOAD

MODES=( 0 1 )
CHANNELS=( 0094 0131 0171 0193 0211 0304 0335 1600 1700 HMIB HMII HMID HMIBC HMIIF HMIIC )
RESOLUTIONS=( 4096 2048 1024 512 )

# Mode selection. Select operating mode
val_mod=false

res_sel=512

# ALL CHANNEL DYNAMIC
# Infinite loop to continue grabbing images from SDO database
while :
do
	for CHANNEL in ${CHANNELS[@]}
	do
		FILENAME="latest_"$res_sel"_"$CHANNEL".jpg"
		URL=$LATEST_URL/$FILENAME

		# wget command
		wget -N -nd --no-check-certificate --inet4-only $URL --directory-prefix=$LOCALDIR
	done

	# Reset tty2
	echo ^v^o > /dev/tty2

	sudo fbi -a -T 2 -noverbose -t 30 $LOCALDIR/*
	echo "LOOP COMPLETE"
	sleep 15m
done
