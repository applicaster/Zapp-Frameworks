package com.applicaster.firebasepushpluginandroid.notification

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.RingtoneManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.NotificationCompat
import com.applicaster.firebasepushpluginandroid.push.PushMessage
import com.applicaster.util.APLogger
import com.applicaster.util.StringUtil
import com.bumptech.glide.Glide
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext


class NotificationUtil {

    companion object {
        private val TAG = NotificationUtil::class.java.canonicalName

        private const val CUSTOM_SOUND_KEY = "custom sound"
        private const val DEFAULT_SND = "system_default"
        private const val SILENT_PUSH_KEY = "silent"

        suspend fun createCustomNotification(
                context: Context,
                pushMessage: PushMessage,
                notificationIconId: Int
        ): Notification {
            val title = pushMessage.title
            val contentText = pushMessage.contentText
            val sound = pushMessage.sound
            val iconUrl = pushMessage.icon
            val messageId = pushMessage.messageId

            val largeIconBitmap: Bitmap? =
                    when {
                        iconUrl.isNotEmpty() -> fetchImage(context, iconUrl)
                        else -> null
                    }

            val imageBitmap: Bitmap? = pushMessage.image?.let {
                fetchImage(context, pushMessage.image.toString())
            }

            val notificationBuilder = NotificationCompat.Builder(context, pushMessage.channel)
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

                if (null != imageBitmap) {
                    setStyle(NotificationCompat
                            .BigPictureStyle(this)
                            .bigPicture(imageBitmap))
                    setLargeIcon(imageBitmap) // override large icon with image
                }
            }
            return notificationBuilder.build()
        }

        // fetch and downscale remote image asynchronously
        private suspend fun fetchImage(context: Context, url: String): Bitmap? {
            return withContext(Dispatchers.Default) {
                try {
                    @Suppress("BlockingMethodInNonBlockingContext")
                    return@withContext Glide.with(context.applicationContext)
                            .asBitmap()
                            .load(url)
                            .submit().get()
                } catch (e: Exception) {
                    APLogger.error(TAG, "Failed to fetch image $url", e)
                }
                return@withContext null
            }
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

        @JvmStatic
        fun getSoundUri(sound: String?, context: Context): Uri? {
            if (StringUtil.isEmpty(sound) || DEFAULT_SND.equals(sound, ignoreCase = true)) {
                return Settings.System.DEFAULT_NOTIFICATION_URI
            }

            //no sound push
            if (SILENT_PUSH_KEY.equals(sound, ignoreCase = true)) {
                return null
            }

            //custom sound push
            val custom: Uri? = getSoundUriByName(sound!!, context)
            return custom ?: Settings.System.DEFAULT_NOTIFICATION_URI
        }

        private fun getSoundUriByName(soundName: String, context: Context): Uri? {
            var res: Uri? = null
            if (StringUtil.isEmpty(soundName)) {
                return res
            }
            val id = context.resources.getIdentifier(soundName, "raw", context.packageName)
            if (id != 0) {
                res = Uri.parse("android.resource://${context.packageName}/$id")
            }
            return res
        }

        private fun getContentIntent(context: Context): PendingIntent {
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }
}