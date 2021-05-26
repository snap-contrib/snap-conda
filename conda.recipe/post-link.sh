SNAP_PKG='esa-snap_sentinel_unix_8_0.sh'

MESSAGE_FILE=$PREFIX/.messages.txt

chmod 755 $PREFIX/snap-src/$SNAP_PKG

$PREFIX/snap-src/$SNAP_PKG -q -dir $PREFIX/snap >> ${MESSAGE_FILE} 2>&1  

rm -fr $PREFIX/snap-src/$SNAP_PKG

SNAP_HOME="$PREFIX/snap/.snap"

echo "SNAP_HOME is $SNAP_HOME" &>> $PREFIX/.messages.txt
echo "updating snap.userdir in  $PREFIX/snap/etc/snap.properties " >> ${MESSAGE_FILE} 2>&1  
sed -i "s!#snap.userdir=!snap.userdir=$SNAP_HOME!g" $PREFIX/snap/etc/snap.properties >> ${MESSAGE_FILE} 2>&1  

echo "updating default_userdir in $PREFIX/snap/etc/snap.conf " >> ${MESSAGE_FILE} 2>&1  
sed -i "s!\${HOME}!$PREFIX/snap/!g" $PREFIX/snap/etc/snap.conf >> ${MESSAGE_FILE} 2>&1  

echo "updating snap modules" >> ${MESSAGE_FILE} 2>&1  
#$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all >> ${MESSAGE_FILE} 2>&1   

$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && sleep 2 && pkill -TERM -f "snap/jre/bin/java"
done

echo "Give read/write permissions for snap home folder" >> ${MESSAGE_FILE} 2>&1  
chmod -R 777 $SNAP_HOME &>> $PREFIX/.messages.txt

echo "setting python_version variable" >> ${MESSAGE_FILE} 2>&1  
python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )
echo "python_version is $python_version " >> ${MESSAGE_FILE} 2>&1  

# retrieving jpy wheel to copy in $SNAP_HOME/snap-python/snappy directory
jpy_file=$(find ${PREFIX}/jpy_wheel -name "jpy-*-cp*-cp*-linux_x86_64.whl")
if [ -z "$jpy_file" ]
then
	echo "Jpy has not been installed correctly" >> ${MESSAGE_FILE} 2>&1  
	exit 1
fi

jpy_filename=$(basename $jpy_file)

# check if $SNAP_HOME/snap-python/snappy directory exists, if not create it
if [ -d "$SNAP_HOME/snap-python/snappy" ]
then
	echo "$SNAP_HOME/snap-python/snappy directory exists"  >> ${MESSAGE_FILE} 2>&1  
else
	echo "creating $SNAP_HOME/snap-python/snappy directory"  >> ${MESSAGE_FILE} 2>&1  
	mkdir -p $SNAP_HOME/snap-python/snappy >> ${MESSAGE_FILE} 2>&1  
fi

# copying jpy wheel to snappy folder
echo "Copying $jpy_file to $SNAP_HOME/snap-python/snappy/$jpy_filename" >> ${MESSAGE_FILE} 2>&1  
echo "running: cp ${jpy_file} $SNAP_HOME/snap-python/snappy/$jpy_filename" >> ${MESSAGE_FILE} 2>&1  
cp ${jpy_file} $SNAP_HOME/snap-python/snappy/$jpy_filename >> ${MESSAGE_FILE} 2>&1  

echo "running snappy-conf: $PREFIX/snap/bin/snappy-conf $PREFIX/bin/python" >> ${MESSAGE_FILE} 2>&1  
$PREFIX/snap/bin/snappy-conf $PREFIX/bin/python$python_version >> ${MESSAGE_FILE} 2>&1   

echo " copying snappy folder to site-packages to make it importable: cp -r $SNAP_HOME/snap-python/snappy $PREFIX/lib/python${python_version}/site-packages"
cp -r $SNAP_HOME/snap-python/snappy $PREFIX/lib/python${python_version}/site-packages >> ${MESSAGE_FILE} 2>&1  

echo "Setting execution permissions to gdal.jar" >> ${MESSAGE_FILE} 2>&1  
chmod +x $SNAP_HOME/auxdata/gdal/gdal-3-0-0/java/gdal.jar >> ${MESSAGE_FILE} 2>&1  

## Jdk from package requirements
#echo "Setting the default version of java to 1.7" &>> $PREFIX/.messages.txt
#JAVA_PATH=/opt/anaconda/pkgs/java-1.7.0-openjdk-cos6-x86_64-1.7.0.131-h06d78d4_0/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.131.x86_64/jre/bin/java
#echo "Java binary: $JAVA_PATH" &>> $PREFIX/.messages.txt
## update java alternatives
#alternatives --install /usr/bin/java java $JAVA_PATH 1 &>> $PREFIX/.messages.txt
## choose the java version you just installed 
#alternatives --set java $JAVA_PATH &>> $PREFIX/.messages.txt


# adding snap binaries to  PATH
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d

mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

echo "#!/bin/bash 
export PATH=$PREFIX/snap/bin:\$PATH" >> $ACTIVATE_DIR/env_vars.sh

echo "#!/bin/bash
PATH=\$(echo \$PATH | sed -e 's@$PREFIX/snap/bin:@@g')
export PATH=\$PATH"  >>  $DEACTIVATE_DIR/env_vars.sh

