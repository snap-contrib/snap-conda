chmod 755 $PREFIX/snap-src/esa-snap_all_unix_7_0.sh

$PREFIX/snap-src/esa-snap_all_unix_7_0.sh -q -dir $PREFIX/snap &> /tmp/snap_build.log


echo "retrieving user's home"
if [ -d "/home/nobody" ];
then
	HOME_FOLDER="/home/nobody"
	echo "User home is "$HOME_FOLDER
elif [ -f "/etc/profile.d/puppet.sh" ];
then
	PROPERTY_FILE=/etc/profile.d/puppet.sh
	PROP_KEY=CIOP_USERNAME
	CIOP_USERNAME=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
	HOME_FOLDER=/home/$CIOP_USERNAME
	echo "User home is "$HOME_FOLDER
else
	HOME_FOLDER=$HOME
	echo "User home is "$HOME_FOLDER
	SNAP_USER=$(basename $HOME)
fi

SNAP_HOME="$HOME_FOLDER/.snap"

echo "HOME_FOLDER is $HOME_FOLDER" &>> /tmp/snap_build.log

echo "updating snap.userdir in  $PREFIX/snap/etc/snap.properties " &>> /tmp/snap_build.log
sed -i "s!#snap.userdir=!snap.userdir=$SNAP_HOME!g" $PREFIX/snap/etc/snap.properties &>> /tmp/snap_build.log

echo "updating snap modules" &>> /tmp/snap_build.log
$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all  &> /tmp/snap_update.log


echo "Give read/write permissions for snap home folder"  &>> /tmp/snap_build.log
if [[ ! -z "$SNAP_USER" ]] 
then 
	echo "Giving permissions to user $USER" &>> /tmp/snap_build.log
	chown -R $SNAP_USER $SNAP_HOME &>> /tmp/snap_build.log
elif [[ ! -z "$CIOP_USERNAME" ]]
then
	echo "Giving permissions to ciop user $CIOP_USERNAME" &>> /tmp/snap_build.log
	chown -R $CIOP_USERNAME:ciop $SNAP_HOME	 &>> /tmp/snap_build.log
else
	echo "Giving permissions to nobody user" &>> /tmp/snap_build.log
	chmod -R 777 $SNAP_HOME &>> /tmp/snap_build.log
fi



echo "setting python_version variable" &>> /tmp/snap_build.log
python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )

cp -v $PREFIX/jpy_wheel/jpy-*-cp*-cp*m-linux_x86_64.whl $SNAP_HOME/snap-python/snappy &> /tmp/cp_jpy.log

$PREFIX/snap/bin/snappy-conf $PREFIX/bin/python &> /tmp/snappy_conf.log

cp -v -r $SNAP_HOME/snap-python/snappy $PREFIX/lib/python${python_version}/site-packages &> /tmp/cp_snappy.log






echo "checking for mapred home" &>> /tmp/snap_build.log
if [ -d "/var/lib/hadoop-0.20" ];
then
	echo "copying .snap in mapred home" &>> /tmp/snap_build.log
	cp -r $SNAP_HOME /var/lib/hadoop-0.20 &>> /tmp/snap_build.log
	chown -R mapred:mapred /var/lib/hadoop-0.20/.snap &>> /tmp/snap_build.log
fi

if [ -f $SNAP_HOME/auxdata/gdal/gdal-2.2.0-linux/share/java/gdal.jar ]; then
        echo "Setting execution permissions to gdal.jar" &>> /tmp/snap_build.log
        chmod +x $SNAP_HOME/auxdata/gdal/gdal-2.2.0-linux/share/java/gdal.jar &>> /tmp/snap_build.log
fi

