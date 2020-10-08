package com.applicaster.firebasepushpluginandroid.factory

import android.app.Notification
import com.applicaster.firebasepushpluginandroid.push.PushMessage

interface NotificationFactory {

    suspend fun createNotification(pushMessage: PushMessage): Notification
    fun getSmallIconId(): Int
    fun generateNotificationId(): Int

}