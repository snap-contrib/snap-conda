chmod 755 $PREFIX/snap-src/esa-snap_all_unix_7_0.sh

$PREFIX/snap-src/esa-snap_all_unix_7_0.sh -q -dir $PREFIX/snap &> /tmp/snap_build.log

$PREFIX/snap/bin/snap --nosplash --nogui --modules --update-all  &> /tmp/snap_update.log

echo $HOME/.snap/snap-python  &> /tmp/home.log

python_version=$( $PREFIX/bin/python -c 'import sys; print("{}.{}".format(sys.version_info[0], sys.version_info[1]))' )

mkdir -p $HOME/.snap/snap-python

cp -v $PREFIX/jpy_wheel/jpy-*-cp*-cp*m-linux_x86_64.whl $HOME/.snap/snap-python/snappy &> /tmp/cp_jpy.log

$PREFIX/snap/bin/snappy-conf $PREFIX/bin/python &> /tmp/snappy_conf.log

cp -v -r $HOME/.snap/snap-python/snappy $PREFIX/lib/python${python_version}/site-packages &> /tmp/cp_snappy.log