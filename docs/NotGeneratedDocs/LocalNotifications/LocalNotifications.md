## Local Notification API

This document explain API of the Local Notification.

### General Information

In order to create local notification item  native or react native plugin you have to:

* Add `Generic Local Notifications` plugin to your Zapp project
* In your plugin call open API methods:
	* __Native__: Use `FacadeConnector.connector?.localNotification` this delegate object provides shared to control local notification.
[API Reference](https://github.com/applicaster/AppleApplicasterFrameworks/blob/master/Frameworks/ZappCore/Files/Universal/FacadeConnector/Protocols/FacadeConnectorLocalNotificationProtocol.swift)
	* __React Native__: Import to your code `import { localNotificationBridge } from "@applicaster/zapp-react-native-bridge/LocalNotification";` use shared API to control local notification.
[API Reference](https://github.com/applicaster/QuickBrick/blob/master/packages/zapp-react-native-bridge/LocalNotification/index.js)
* To schdule local notfication with request must be passed payload dictionary, that define rules of the creation local notifications.

#### tvOS

Local Notifications in tvOS is very limited, API provides only ability to update icon badge.
Red icon badge will be shown if user not inside application.

###### Payload API

```
 {
    identifier: String,
    unixTimestamp: Long,
 }
```

#### iOS

Local Notifications for iOS provide rich notificaiton settings all availible features described in API section.

###### Payload API

```
 {
    identifier: String,
    title: String,
    body: String,
    unixTimestamp: Long,
    defaultActionUrl : String,
    dismissActionUrl : String,
    actions:[
        {
            identifier: String,
            title: String,
            url: String,
            buttonType: String
        }
    ],
    attachments: [
        {
            imageUri: String,
            iosOverrideImageUri: String,
            androidOverrideImageUri: String,
        }
    ]
 }
```

| Key | Type | Description | Optional
|--------|--------|--------|--------|
|identifier|String|Unique Identifier of the Local Notification Item|-|
|title|String|Title of the Item|-|
|body|String|Item's body text|YES|
|unixTimestamp|Long|Unix Timestamp date in seconds, defines when notification should fire|YES|
|defaultActionUrl|String|URL that will be called, if user tap on local notification|YES|
|dismissActionUrl|String|URL that will be called, if use erased local notification|YES|
|actions|Array|Contains Array of dictionaries that represents Action Button|YES|
|attachments|Array|Contains Array of dictionaries that represents Attachments|YES|

__Actions Data__

| Key | Type | Description | Optional
|--------|--------|--------|--------|
|identifier|String|Unique Identifier of the Action button Item|-|
|title|String|Title of the Action Item|-|
|url|String|URL that will be called, if user tap on the action button|YES|
|buttonType|String|Type of the action button|YES||-|

__Action Button Data__

| Key | Type | Description |
|--------|--------|--------|
|default|String|Default action button, in case not defined will be used as default|
|danger|String|Danger action button that defines as a red, to make some destructive calls|

__Attachments__

Maximun attachment image size can be checked [Apple Docs](https://developer.apple.com/documentation/usernotifications/unnotificationattachment)

Currently supported only 1 attachment image, more items will be ignored.

| Key | Type | Description | Optional
|--------|--------|--------|--------|
|imageUri|String|Item name of the local stored image, example `myImage.png`|-|
|iosOverrideImageUri|String|Has bigger priority, item name of the local stored image, example `myImage.png`|YES|
|androidOverrideImageUri|String|Android Item name of the local stored image, example `myImage.png`|YES|
