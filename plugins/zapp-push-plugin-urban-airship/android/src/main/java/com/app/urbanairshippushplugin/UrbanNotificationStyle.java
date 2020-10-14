package com.app.urbanairshippushplugin;

/**
 * Created by user on 12/6/16.
 */
public enum UrbanNotificationStyle {
        CustomImage, CustomOneImage, None;

        public static UrbanNotificationStyle getType(String name){
            UrbanNotificationStyle result = None;
            if (("custom_image").equalsIgnoreCase(name)){
                result = UrbanNotificationStyle.CustomImage;
            }

            if (("custom_one_image").equalsIgnoreCase(name)){
                result = UrbanNotificationStyle.CustomOneImage;
            }

            return result;
        }
    }