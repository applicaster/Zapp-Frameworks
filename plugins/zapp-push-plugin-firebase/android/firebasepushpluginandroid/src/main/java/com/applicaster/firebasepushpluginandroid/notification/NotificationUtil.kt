package com.applicaster.firebasepushpluginandroid.notification

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.RingtoneManager
import android.net.Uri
import androidx.core.app.NotificationCompat
import com.applicaster.util.StringUtil
import com.bumptech.glide.Glide
import com.applicaster.firebasepushpluginandroid.FIREBASE_DEFAULT_CHANNEL_ID
import com.applicaster.firebasepushpluginandroid.push.PushMessage
import com.applicaster.util.push.PushUtil


class NotificationUtil {

    companion object {
        private val TAG = NotificationUtil::class.java.canonicalName

        private const val CUSTOM_SOUND_KEY = "custom sound"
        private const val SILENT_PUSH_KEY = "silent"

        private var title: String = ""
        private var contentText: String = ""
        private var sound: Uri? = Uri.EMPTY
        private var iconUrl: String = ""
        private var messageId: String = ""
        private var provider = "Firebase push provider"

        fun createCustomNotification(
            context: Context,
            pushMessage: PushMessage,
            notificationIconId: Int,
            notificationId: Int
        ): Notification {

            title = pushMessage.title
            contentText = pushMessage.contentText
            sound = Uri.parse(pushMessage.sound)
            iconUrl = pushMessage.icon
            messageId = pushMessage.messageId
            provider = "Firebase push provider"

            var largeIconBitmap: Bitmap? = null
            if (iconUrl.isNotEmpty()) {
                 largeIconBitmap = Glide.with(context.applicationContext).asBitmap().load(iconUrl).submit().get()
            }

            val notificationBuilder = NotificationCompat.Builder(context, FIREBASE_DEFAULT_CHANNEL_ID)
            notificationBuilder.apply {
                setSmallIcon(notificationIconId)
                setLargeIcon(largeIconBitmap)
                // Dismiss Notification
                setAutoCancel(true)
                // Set the alert to alert only once
                setOnlyAlertOnce(true)
                //set defaults for lights and vibrations.
                setDefaults(NotificationCompat.DEFAULT_ALL)
                //set the sound
                setSound(sound)
                //set content title
                setContentTitle(title)
                //set content text
                setContentText(contentText)
                //set the content intent
                setContentIntent(getContentIntent(context))
            }

            return notificationBuilder.build()
        }

        fun getPushSound(message: PushMessage, context: Context): Uri? {
            //no sound push
            if (isSilent(message)) {
                return null
            }
            //custom sound push
            val custom = getSoundUriByName(CUSTOM_SOUND_KEY, context)
            return custom ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        }

        private fun isSilent(message: PushMessage): Boolean {
            return SILENT_PUSH_KEY.equals(CUSTOM_SOUND_KEY, ignoreCase = true)
        }

        private fun getSoundUriByName(soundName: String, context: Context): Uri? {
            var res: Uri? = null
            if (StringUtil.isEmpty(soundName)) {
                return res
            }
            val id = context.resources.getIdentifier(soundName, "raw", context.packageName)
            if (id != 0) {
                res = Uri.parse("android.resource://" + context.packageName + "/" + id)
            }
            return res
        }

        private fun getContentIntent(context: Context): PendingIntent {
            val intent = Intent()
            intent.apply {
                setClassName(context, "com.applicaster.componentsapp.IntroActivity")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }
}