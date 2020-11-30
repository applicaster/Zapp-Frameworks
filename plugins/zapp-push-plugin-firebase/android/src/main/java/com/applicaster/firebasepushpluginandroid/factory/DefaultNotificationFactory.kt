package com.applicaster.firebasepushpluginandroid.factory

import android.app.Notification
import android.content.Context
import com.example.firebasepushpluginandroid.R
import com.applicaster.firebasepushpluginandroid.notification.NotificationUtil
import com.applicaster.firebasepushpluginandroid.push.PushMessage
import kotlin.random.Random

class DefaultNotificationFactory(private val context: Context) : NotificationFactory {

    override fun createNotification(pushMessage: PushMessage): Notification {
        return NotificationUtil.createCustomNotification(
                context,
                pushMessage,
                getSmallIconId()
        )
    }

    override fun getSmallIconId(): Int {
        return R.drawable.notification_icon
    }

    override fun generateNotificationId(): Int = Random.nextInt(from = 0, until = 10000)
}