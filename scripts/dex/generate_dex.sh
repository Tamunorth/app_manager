LOCAL_DIR=$(cd `dirname $0`; pwd)
apkPath="build/app/outputs/flutter-apk/app-release.apk"
rm -rf $LOCAL_DIR/tmp
rm -rf $LOCAL_DIR/server.jar
$LOCAL_DIR/apktool.sh d $apkPath -r -f -o $LOCAL_DIR/tmp
rm -rf $LOCAL_DIR/tmp/lib
rm -rf $LOCAL_DIR/tmp/assets
rm -rf $LOCAL_DIR/tmp/res
rm -rf $LOCAL_DIR/tmp/resources.arsc
rm -rf $LOCAL_DIR/tmp/AndroidManifest.xml
$LOCAL_DIR/apktool.sh b -f $LOCAL_DIR/tmp -o $LOCAL_DIR/server.jar
rm -rf $LOCAL_DIR/tmp