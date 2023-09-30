#! /bin/bash
cd "$(dirname "$0")"

# Set the backlight on the Hyperpixel screen
sudo pigpiod
pigs hp 19 100 50000

#SDO Website URL
LATEST_URL=https://sdo.gsfc.nasa.gov/assets/img/latest

# DOWNLOAD PATH
LOCALDIR=./IMG_DOWNLOAD

MODES=( 0 1 )
CHANNELS=( 0094 0131 0171 0193 0211 0304 0335 1600 1700 HMIB HMII HMID HMIBC HMIIF HMIIC )
RESOLUTIONS=( 4096 2048 1024 512 )

# Mode selection. Select operating mode
val_mod=false

while ! $val_mod
do
	echo -n "Select Mode (0 : Single Channel Static, 1 : All Channel Dynamic)"
	read mod_sel

	if [[ " ${MODES[*]} " =~ " ${mod_sel} " ]]; then
		val_mod=true
		echo $mod_sel
	else
		echo "Invalid Mode"
	fi
done

# Resolution selection. Checks if resolution is valid by checking for presence in RESOLUTIONS array
val_res=false

while ! $val_res
do
	echo -n "Select Resolution (4096 2048 1024 512): "
	read res_sel

	if [[ " ${RESOLUTIONS[*]} " =~ " ${res_sel} " ]]; then
		val_res=true
		echo $res_sel
	else
		echo "Invalid Resolution"
	fi
done

# SINGLE CHANNEL STATIC
if [ $mod_sel -eq 0 ]; then
	# Channel selection. Checks if channel is valid by checking for presence in CHANNELS array
	val_ch=false

	while ! $val_ch
	do
		echo -n "Select Channel (0094 0131 0171 0193 0211 0304 0335 1600 1700 HMIB HMII HMID HMIBC HMIIF HMIIC): "
		read ch_sel

		if [[ " ${CHANNELS[*]} " =~ " ${ch_sel} " ]]; then
			val_ch=true
			echo $ch_sel
		else
			echo "Invalid Channel"
		fi
	done

	FILENAME="latest_"$res_sel"_"$ch_sel".jpg"
	URL=$LATEST_URL/$FILENAME

	# Infnite loop to continue grabbing images from SDO database
	while :
	do
		# wget command
		wget -N -nd --no-check-certificate --inet4-only $URL --directory-prefix=$LOCALDIR

		sudo fbi -a -T 2 -noverbose $LOCALDIR/$FILENAME
		echo "LOOP COMPLETE"
		sleep 15m
	done
fi

# ALL CHANNEL DYNAMIC
if [[ $mod_sel -eq 1 ]]; then
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
		sudo systemctl restart getty@tty2.service

		sudo fbi -a -T 2 -noverbose -t 30 $LOCALDIR/*
		echo "LOOP COMPLETE"
		sleep 15m
	done
fi
