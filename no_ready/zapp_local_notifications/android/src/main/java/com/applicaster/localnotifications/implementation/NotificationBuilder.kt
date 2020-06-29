package com.applicaster.localnotifications.implementation

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.text.TextUtils
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.applicaster.util.OSUtil
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import java.net.URL
import kotlin.math.abs

class NotificationBuilder(private val context: Context) {

    private var manager: NotificationManagerCompat = NotificationManagerCompat.from(context)

    private var channelId = DEFAULT_CHANNEL_ID
    private var channelName = DEFAULT_CHANNEL_NAME

    fun withChannel(channelId: String, channelName: String): NotificationBuilder {
        this.channelId = channelId
        this.channelName = channelName
        return this
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_DEFAULT)
        manager.createNotificationChannel(channel)
    }

    fun presentNotification(notification: LocalNotificationPayload) {

        ensureChannel()

        val pi = PendingIntent.getActivity(
                context, 0,
                wrap(context, notification.defaultActionUrl),
                PendingIntent.FLAG_UPDATE_CURRENT)

        val builder = NotificationCompat.Builder(context, channelId)

        // Main data
        builder.setContentTitle(notification.title)
        builder.setContentText(notification.body)
        builder.setContentIntent(pi)
        builder.setAutoCancel(true)

        val notificationId = mapId(notification.identifier)

        // Default small icon
        try {
            val applicationInfo = context.packageManager.getApplicationInfo(
                    context.packageName, PackageManager.GET_META_DATA)
            builder.setSmallIcon(applicationInfo.icon)
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }

        // Dismiss intent
        if (!TextUtils.isEmpty(notification.dismissActionUrl)) {
            val dpi = PendingIntent.getActivity(context, 0,
                    wrap(context, notification.dismissActionUrl),
                    PendingIntent.FLAG_UPDATE_CURRENT)
            builder.setDeleteIntent(dpi)
        }

        notification.actions?.forEach {
            builder.addAction(map(context, it, notificationId))
        }

        // Images
        GlobalScope.launch(Dispatchers.Main) {
            handleImages(builder, notification)
            manager.notify(notificationId, builder.build())
        }
    }

    private suspend fun resolveImage(uri: String,
                                     default: (() -> Bitmap?)? = null) : Bitmap? {
        return withContext(Dispatchers.IO) {
            try {
                val input = URL(uri).openStream()
                BitmapFactory.decodeStream(input)
            } catch (e: IOException) {
                default?.invoke()
            }
        }
    }

    private suspend fun handleImages(notification: NotificationCompat.Builder,
                                     payload: LocalNotificationPayload) {

        // Icons
        if (null != payload.android) {
            if (!TextUtils.isEmpty(payload.android.iconBigUri)) {
                notification.setLargeIcon(resolveImage(payload.android.iconBigUri))
            }
            if (!TextUtils.isEmpty(payload.android.iconSmallUri)) {
                // todo: resolve as resource, external images are not allowed
            }
        }

        // Attachments
        if (null != payload.attachments && !payload.attachments.isEmpty()) {
            for (attachment in payload.attachments) {
                var imageUri: String? = null
                if (!TextUtils.isEmpty(attachment.androidOverrideImageUri)) {
                    imageUri = attachment.androidOverrideImageUri
                } else if (!TextUtils.isEmpty(attachment.imageUri)) {
                    imageUri = attachment.imageUri
                }
                if (null != imageUri) {
                    resolveImage(imageUri)?.let {
                        notification.setStyle(NotificationCompat.BigPictureStyle().bigPicture(it))
                    }
                    break
                }
            }
        }
    }

    private fun wrap(context: Context, url: String?): Intent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: throw RuntimeException("Application missing launch intent")
        intent.action = Intent.ACTION_VIEW
        intent.addCategory(OSUtil.getPackageName())
        if (!TextUtils.isEmpty(url)) {
            intent.data = Uri.parse(url)
        }
        return intent
    }

    private fun map(context: Context,
                    action: LocalNotificationPayload.Action,
                    notificationId: Int): NotificationCompat.Action {

        // Actual intent
        val intent = wrap(context, action.url)

        // Wrapped intent so we can dismiss the notification on button clicked
        val wrapperIntent = Intent(context, LocalNotificationActionRouter::class.java)
        wrapperIntent.action = Intent.ACTION_VIEW
        wrapperIntent.addCategory(OSUtil.getPackageName())
        wrapperIntent.putExtra(NOTIFICATION_ID_EXTRA, notificationId)
        wrapperIntent.putExtra(WRAPPED_INTENT_EXTRA, intent)

        val pi = PendingIntent.getBroadcast(context,
                0,
                wrapperIntent,
                PendingIntent.FLAG_UPDATE_CURRENT)
        return NotificationCompat.Action(0, action.title, pi)
    }

    companion object {

        private const val NOTIFICATION_ID_BASE = 3000

        // hack to dismiss notification when action button is clicked
        const val WRAPPED_INTENT_EXTRA = "wrapped_intent"
        const val NOTIFICATION_ID_EXTRA = "notificationId"

        private const val DEFAULT_CHANNEL_ID = "LOCAL_NOTIFICATIONS_DEFAULT_CHANNEL"
        private const val DEFAULT_CHANNEL_NAME = "Reminders"

        @JvmStatic
        fun cancel(context: Context, identifiers: List<String>) {
            val manager = NotificationManagerCompat.from(context)
            for (identifier in identifiers) {
                val id = mapId(identifier)
                manager.cancel(id)
            }
        }

        private fun mapId(identifier: String): Int {
            return NOTIFICATION_ID_BASE + abs(identifier.hashCode())
        }
    }

}