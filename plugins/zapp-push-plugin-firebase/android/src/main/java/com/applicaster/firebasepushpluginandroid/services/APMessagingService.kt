package com.applicaster.firebasepushpluginandroid.services

import androidx.core.app.NotificationManagerCompat
import android.util.Log
import com.applicaster.firebasepushpluginandroid.factory.DefaultNotificationFactory
import com.applicaster.firebasepushpluginandroid.push.PushMessage
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage


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

        Log.i(TAG, "Message Received: title: [${remoteMessage?.notification?.title}], body: [${remoteMessage?.notification?.body}]")

        processMessageSync(message = remoteMessage)
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
        Log.i(TAG, "Deleted messages on server")
    }

    /**
     * Called when there was an error sending an upstream message.
     * @param msgId of the upstream message sent using send(RemoteMessage)
     * @param exception description of the error, typically a {@see SendException}
     */
    override fun onSendError(msgId: String, exception: Exception) {
        super.onSendError(msgId, exception)
        exception.printStackTrace()
        Log.e(TAG, "Received error: $msgId")
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.i(TAG, "onTokenRefresh")
    }

    private fun processMessageSync(message: RemoteMessage?) {
        var title: String? = ""
        var body: String? = ""
        var tag: String? = ""

        if (message?.data?.isEmpty() == true) {
            title = message.notification?.title
            body = message.notification?.body
            tag = message.notification?.tag

        } else {

            val data = message?.data
            if (data?.containsKey("title") == true) title = data["title"]
            if (data?.containsKey("body") == true) body = data["body"]
            if (data?.containsKey("tag") == true) tag = data["tag"]

        }
        val notificationFactory = DefaultNotificationFactory(applicationContext)
        val pushMsg = PushMessage(
            body = body.orEmpty() ,
            title = title.orEmpty(),
            tag = tag.orEmpty(),
            contentText = body.orEmpty(),
            messageId = message?.messageId.orEmpty()
        )
        notify(notificationFactory, pushMsg)
    }

    // set up notification manager, create notification and notify
    private fun notify(notificationFactory: DefaultNotificationFactory, pushMessage: PushMessage) {
        val notification = notificationFactory.createNotification(pushMessage = pushMessage)
        with(NotificationManagerCompat.from(this)) {
            notify(notificationFactory.generateNotificationId(), notification)
        }
    }
}