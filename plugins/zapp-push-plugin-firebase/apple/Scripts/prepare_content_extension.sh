#Finds the project level dir
export ZAPP_HOME=`find /Users/$USER -name ZappiOS | head -n 1`
echo "The ZAPP_HOME dir is $ZAPP_HOME"

# Get NotificationService.swift file path
old_file_path=`find "$ZAPP_HOME" -maxdepth 3 -name "NotificationViewController.swift" | tail -1`
new_file_path="$ZAPP_HOME/node_modules/@applicaster/zapp-push-plugin-firebase/apple/extensions/content/NotificationViewController.swift"

echo "Replacing file: $old_file_path"

if [ -z "$old_file_path" ]; then
    echo "Can't find the NotificationViewController.swift file, going to skip this script."
else
    mv $new_file_path $old_file_path
fi