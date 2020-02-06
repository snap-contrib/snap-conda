#!/bin/bash

echo "retrieving user's home" &> /tmp/snap_remove.log
if [ -d "/home/nobody" ];
then
        HOME_FOLDER="/home/nobody"
elif [ -f "/etc/profile.d/puppet.sh" ];
then
        PROPERTY_FILE=/etc/profile.d/puppet.sh
        PROP_KEY=CIOP_USERNAME
        CIOP_USERNAME=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
        HOME_FOLDER=/home/$CIOP_USERNAME
else
        HOME_FOLDER=$HOME
fi

SNAP_HOME="$HOME_FOLDER/.snap"

echo "removing SNAP_HOME $SNAP_HOME" &>> /tmp/snap_remove.log
rm -fr $SNAP_HOME &>> /tmp/snap_remove.log

echo "removing SNAP package $PREFIX/snap" &>> /tmp/snap_remove.log
rm -fr $PREFIX/snap &>> /tmp/snap_remove.log
