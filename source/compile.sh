# Create necessary directories and clone repository
mkdir ${DATA_DIR}/vendor-reset
mkdir -p ${DATA_DIR}/vendor-reset/vendorreset/lib/modules/${UNAME}
cd ${DATA_DIR}/vendor-reset
git clone https://github.com/gnif/vendor-reset
cd ${DATA_DIR}/vendor-reset/vendor-reset
git checkout master

# Compile Kernel Module to temporary directory
make build -j${CPU_COUNT}
make INSTALL_MOD_PATH=/${DATA_DIR}/vendor-reset/vendorreset install -j${CPU_COUNT}

# Clean up temporary directory
cd ${DATA_DIR}/vendor-reset/vendorreset/lib/modules/${UNAME}/
rm ${DATA_DIR}/vendor-reset/vendorreset/lib/modules/${UNAME}/* 2>/dev/null
find . -depth -exec rmdir {} \;  2>/dev/null

# Create Slackware package
PLUGIN_NAME="gnif_vendor_reset"
BASE_DIR="${DATA_DIR}/vendor-reset/vendorreset"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"

mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME
$PLUGIN_NAME: Source: https://github.com/gnif/vendor-reset
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz.md5