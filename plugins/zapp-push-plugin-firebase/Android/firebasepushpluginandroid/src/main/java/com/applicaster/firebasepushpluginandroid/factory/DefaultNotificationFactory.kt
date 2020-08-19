package com.applicaster.firebasepushpluginandroid.factory

import android.app.Notification
import android.content.Context
import android.net.Uri
import com.applicaster.util.OSUtil
import com.example.firebasepushpluginandroid.R
import com.applicaster.firebasepushpluginandroid.notification.NotificationUtil
import com.applicaster.firebasepushpluginandroid.push.PushMessage
import kotlin.random.Random

class DefaultNotificationFactory(private val context: Context) : NotificationFactory {

    override fun createNotification(pushMessage: PushMessage): Notification {
        return NotificationUtil.createCustomNotification(
            context,
            pushMessage,
            getSmallIconId(),
            generateNotificationId()
            )
    }

    override fun getSmallIconId(): Int {
        var id = OSUtil.getDrawableResourceIdentifier("notification_icon")
        if (id == 0) { id = R.drawable.ic_sms }
        return id
    }

    override fun generateNotificationId(): Int = Random.nextInt(from = 0, until = 10000)
}