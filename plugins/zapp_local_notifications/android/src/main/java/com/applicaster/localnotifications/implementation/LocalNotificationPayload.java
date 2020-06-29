package com.applicaster.localnotifications.implementation;

import java.util.ArrayList;
import java.util.List;

public class LocalNotificationPayload {

    public static class Action {
        public String identifier;
        public String title;
        public String url;
        public String buttonType;
    }

    public static class Attachment {
        public String imageUri;
        public String androidOverrideImageUri;
    }

    public static class AndroidData {
        public String iconBigUri;
        public String iconSmallUri;
    }

    public String identifier;
    public String title;
    public String body;
    public Long unixTimestamp; // in seconds
    public List<Action> actions = new ArrayList<>();
    public String defaultActionUrl;
    public String dismissActionUrl;
    public List<Attachment> attachments = new ArrayList<>();
    public AndroidData android;
}
