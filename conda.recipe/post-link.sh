chmod 755 $PREFIX/snap-src/esa-snap_all_unix_7_0.sh

$PREFIX/snap-src/esa-snap_all_unix_7_0.sh -q -dir $PREFIX/snap &>> $PREFIX/.messages.txt


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

echo "HOME_FOLDER is $HOME_FOLDER" &>> $PREFIX/.messages.txt

echo "updating snap.userdir in  $PREFIX/snap/etc/snap.properties " &>> $PREFIX/.messages.txt
sed -i "s!#snap.userdir=!snap.userdir=$SNAP_HOME!g" $PREFIX/snap/etc/snap.properties &>> $PREFIX/.messages.txt

echo "updating snap modules" &>> /tmp/snap_build.log
$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all  &> /tmp/snap_update.log


echo "Give read/write permissions for snap home folder"  &>> $PREFIX/.messages.txt
if [[ ! -z "$SNAP_USER" ]] 
then 
	echo "Giving permissions to user $USER" &>> $PREFIX/.messages.txt
	chown -R $SNAP_USER $SNAP_HOME &>> /tmp/snap_build.log
elif [[ ! -z "$CIOP_USERNAME" ]]
then
	echo "Giving permissions to ciop user $CIOP_USERNAME" &>> $PREFIX/.messages.txt
	chown -R $CIOP_USERNAME:ciop $SNAP_HOME	 &>> $PREFIX/.messages.txt
else
	echo "Giving permissions to nobody user" &>> $PREFIX/.messages.txt
	chmod -R 777 $SNAP_HOME &>> /tmp/snap_build.log
fi



echo "setting python_version variable" &>> $PREFIX/.messages.txt
python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )

cp -v $PREFIX/jpy_wheel/jpy-*-cp*-cp*m-linux_x86_64.whl $SNAP_HOME/snap-python/snappy &> /tmp/cp_jpy.log

$PREFIX/snap/bin/snappy-conf $PREFIX/bin/python &> /tmp/snappy_conf.log

cp -v -r $SNAP_HOME/snap-python/snappy $PREFIX/lib/python${python_version}/site-packages &> /tmp/cp_snappy.log






echo "checking for mapred home" &>> $PREFIX/.messages.txt
if [ -d "/var/lib/hadoop-0.20" ];
then
	echo "copying .snap in mapred home" &>> $PREFIX/.messages.txt
	cp -r $SNAP_HOME /var/lib/hadoop-0.20 &>> $PREFIX/.messages.txt
	chown -R mapred:mapred /var/lib/hadoop-0.20/.snap &>> $PREFIX/.messages.txt
fi

if [ -f $SNAP_HOME/auxdata/gdal/gdal-2.2.0-linux/share/java/gdal.jar ]; then
        echo "Setting execution permissions to gdal.jar" &>> $PREFIX/.messages.txt
        chmod +x $SNAP_HOME/auxdata/gdal/gdal-2.2.0-linux/share/java/gdal.jar &>> $PREFIX/.messages.txt
fi


# Jdk from package requirements
echo "Setting the default version of java to 1.7" &>> $PREFIX/.messages.txt
JAVA_PATH=/opt/anaconda/pkgs/java-1.7.0-openjdk-cos6-x86_64-1.7.0.131-h06d78d4_0/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.131.x86_64/jre/bin/java
echo "Java binary: $JAVA_PATH" &>> $PREFIX/.messages.txt
# update java alternatives
alternatives --install /usr/bin/java java $JAVA_PATH 1 &>> $PREFIX/.messages.txt
# choose the java version you just installed 
alternatives --set java $JAVA_PATH &>> $PREFIX/.messages.txt
