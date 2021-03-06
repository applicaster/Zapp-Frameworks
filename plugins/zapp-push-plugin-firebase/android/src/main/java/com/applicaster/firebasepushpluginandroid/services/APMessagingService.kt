package com.applicaster.firebasepushpluginandroid.services

import android.app.NotificationManager
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import androidx.annotation.WorkerThread
import androidx.core.app.NotificationManagerCompat
import com.applicaster.firebasepushpluginandroid.FIREBASE_DEFAULT_CHANNEL_ID
import com.applicaster.firebasepushpluginandroid.FirebasePushProvider
import com.applicaster.firebasepushpluginandroid.factory.DefaultNotificationFactory
import com.applicaster.firebasepushpluginandroid.push.PushMessage
import com.applicaster.storage.LocalStorage
import com.applicaster.util.APLogger
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


class APMessagingService : FirebaseMessagingService() {

    private val TAG = APMessagingService::class.java.canonicalName
    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options

        APLogger.info(TAG, "Message Received: title: [${remoteMessage.notification?.title}], body: [${remoteMessage.notification?.body}]")
        processMessageSync(remoteMessage)
    }

    /**
     * Called when the FCM server deletes pending messages. This may be due to:
     *
     * Too many messages stored on the FCM server. This can occur when an app's servers send a bunch
     * of non-collapsible messages to FCM servers while the device is offline.
     * The device hasn't connected in a long time and the app server has recently (within the last
     * 4 weeks) sent a message to the app on that device.
     * It is recommended that the app do a full sync with the app server after receiving this call.
     */
    override fun onDeletedMessages() {
        super.onDeletedMessages()
        APLogger.info(TAG, "Deleted messages on server")
    }

    /**
     * Called when there was an error sending an upstream message.
     * @param msgId of the upstream message sent using send(RemoteMessage)
     * @param exception description of the error, typically a {@see SendException}
     */
    override fun onSendError(msgId: String, exception: Exception) {
        super.onSendError(msgId, exception)
        exception.printStackTrace()
        APLogger.error(TAG, "Received error: $msgId")
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        APLogger.info(TAG, "onTokenRefresh")
    }

    @WorkerThread
    private fun processMessageSync(message: RemoteMessage) {

        var title: String? = ""
        var body: String? = ""
        var tag: String? = ""
        var channel: String? = FIREBASE_DEFAULT_CHANNEL_ID
        var image: Uri? = null
        var groupId: String? = null

        if(null != message.notification) {
            APLogger.info(TAG, "The message received had notification attached, using it to retrieve params")
            title = message.notification?.title
            body = message.notification?.body
            tag = message.notification?.tag
            image = message.notification?.imageUrl
            channel = message.notification?.channelId
        } else {
            APLogger.info(TAG, "The message received had no notification attached, using data to retrieve params")
            if (message.data.containsKey("title")) title = message.data["title"]
            if (message.data.containsKey("body")) body = message.data["body"]
            if (message.data.containsKey("tag")) tag = message.data["tag"]
            if (message.data.containsKey("android_channel_id")) channel = message.data["android_channel_id"]
            if (message.data.containsKey("image") && !TextUtils.isEmpty(message.data["image"])) image = Uri.parse(message.data["image"])
            if (message.data.containsKey("groupid")) groupId = message.data["groupid"]

            if(!groupId.isNullOrBlank() && !shouldPresent(groupId)) {
                APLogger.info(TAG, "Notification belongs to the groupid '$groupId' that was already seen, discarding")
                return
            }
        }
        val action = message.data["url"]

        if(TextUtils.isEmpty(channel)) {
            channel = FIREBASE_DEFAULT_CHANNEL_ID
        }

        var soundUri: Uri? = Settings.System.DEFAULT_NOTIFICATION_URI
        if (!TextUtils.isEmpty(channel)) {
            FirebasePushProvider.getInstance()?.apply {
                channel = validateChannel(channel!!)
                // fetch fallback sound for Android OS < 8.0
                // (we fetch it in any case though)
                soundUri = getSoundForChannel(channel!!)
            }
        }

        val notificationFactory = DefaultNotificationFactory(applicationContext)
        val pushMsg = PushMessage(
                body = body.orEmpty(),
                title = title.orEmpty(),
                tag = tag.orEmpty(),
                clickAction = action.orEmpty(),
                contentText = body.orEmpty(),
                messageId = message.messageId.orEmpty(),
                channel = channel!!,
                sound = soundUri,
                image = image
        )
        notify(notificationFactory, pushMsg)
        if(!groupId.isNullOrBlank()) {
            storePresented(groupId)
        }
    }

    private fun storePresented(tag: String) {
        // store seen time just in case we will later want to improve the logic
        LocalStorage.set(tag, "" + System.currentTimeMillis(), seenNamespace)
    }

    private fun shouldPresent(tag: String): Boolean {
        return LocalStorage.get(tag, seenNamespace).isNullOrEmpty()
    }

    private val seenNamespace get() = FirebasePushProvider.pluginId + ".seenEvents"

    // set up notification manager, create notification and notify
    private fun notify(notificationFactory: DefaultNotificationFactory, pushMessage: PushMessage) {
        val notification = notificationFactory.createNotification(pushMessage)
        // run on UI thread, since some devices can't publish notifications from background threads
        GlobalScope.launch(Dispatchers.Main) {
            with(NotificationManagerCompat.from(this@APMessagingService.applicationContext)) {
                if(pushMessage.tag.isEmpty())
                    notify(notificationFactory.generateNotificationId(), notification)
                else {
                    val id = getId(notificationFactory, pushMessage.tag)
                    notify(pushMessage.tag, id, notification)
                }
            }
        }
    }

    private fun getId(notificationFactory: DefaultNotificationFactory, tag: String): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.activeNotifications?.let {
                val tagged = it.filterNotNull().firstOrNull { tag == it.tag }
                if(null != tagged) {
                    return tagged.id
                }
            }
            return notificationFactory.generateNotificationId()
        }
        return tag.hashCode()
    }
}