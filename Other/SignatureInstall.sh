app_name="QQ"
qq_path="/Applications/QQ.app"
dylib_path="./Products/libQQRedPackHelper.dylib"
tool_lib_path="./Tools/libsubstitute.dylib"
app_bundle_path="/Applications/QQ.app/Contents/MacOS"
cp ${dylib_path} ${app_bundle_path}
cp ${tool_lib_path} ${app_bundle_path}
cp "./Tools/injectionQQ.sh" ${app_bundle_path}
sh ./Tools/install.sh