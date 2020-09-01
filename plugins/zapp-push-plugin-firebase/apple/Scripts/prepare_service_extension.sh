#Finds the project level dir
export ZAPP_HOME=`find /Users/$USER -name ZappiOS | head -n 1`
echo "The ZAPP_HOME dir is $ZAPP_HOME"

# Get NotificationService.swift file path
old_file_path=`find "$ZAPP_HOME" -maxdepth 3 -name "NotificationService.swift" | tail -1`
new_file_path="ZappPushPluginFirebase/extensions/service/NotificationService.swift"

echo "Replacing file: $old_file_path"

if [ -z "$old_file_path" ]; then
    echo "Can't find the NotificationService.swift file, going to skip this script."
else
    mv $new_file_path $old_file_path
fi