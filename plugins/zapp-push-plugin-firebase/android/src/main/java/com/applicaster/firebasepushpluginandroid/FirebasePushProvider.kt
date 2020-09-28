package com.applicaster.firebasepushpluginandroid

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.text.TextUtils
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationManagerCompat
import com.applicaster.firebasepushpluginandroid.notification.NotificationUtil
import com.applicaster.firebasepushpluginandroid.services.APMessagingService
import com.applicaster.plugin_manager.push_plugin.PushContract
import com.applicaster.plugin_manager.push_plugin.helper.PushPluginsType
import com.applicaster.plugin_manager.push_plugin.listeners.PushTagLoadedI
import com.applicaster.plugin_manager.push_plugin.listeners.PushTagRegistrationI
import com.applicaster.util.APLogger
import com.applicaster.util.StringUtil
import com.applicaster.util.TextUtil
import com.google.firebase.iid.FirebaseInstanceId
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine


class FirebasePushProvider : PushContract {

    private val TAG = FirebasePushProvider::class.java.simpleName

    private var pluginsParamsMap: MutableMap<*, *>? = null

    override fun initPushProvider(context: Context) {

        if (Build.VERSION.SDK_INT >= 26) {
            ensureChannels(context)
        }

        FirebaseInstanceId.getInstance().instanceId
                .addOnCompleteListener {
                    if (!it.isSuccessful) {
                        APLogger.error(TAG, "getInstanceId failed", it.exception)
                    } else {
                        val token = it.result?.token
                        APLogger.info(TAG, "Firebase token $token")
                    }
                }
    }

    override fun registerPushProvider(context: Context, registerID: String) {
        initPushProvider(context)
    }

    override fun getPluginType(): PushPluginsType {
        return PushPluginsType.applicaster
    }

    override fun addTagToProvider(
            context: Context?,
            tag: MutableList<String>?,
            pushTagRegistrationListener: PushTagRegistrationI?
    ) {
        GlobalScope.launch(Dispatchers.Main) {
            registerAll(tag, pushTagRegistrationListener)
        }
    }


    override fun removeTagToProvider(
            context: Context?,
            tag: MutableList<String>?,
            pushTagRegistrationListener: PushTagRegistrationI?
    ) {
        GlobalScope.launch(Dispatchers.Main) {
            unregisterAll(tag, pushTagRegistrationListener)
        }
    }

    override fun setPluginParams(params: MutableMap<Any?, Any?>?) {
        pluginsParamsMap = params
    }

    override fun getTagList(context: Context?, listener: PushTagLoadedI?) {

    }

    override fun setPushEnabled(context: Context?, isEnabled: Boolean) {
        val componentName = ComponentName(context!!, APMessagingService::class.java)
        context.packageManager.setComponentEnabledSetting(componentName,
                if (isEnabled) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP)
        APLogger.info(TAG, "Firebase push receiver is now ${if (isEnabled) "enabled" else "disabled"}")
    }

    //region Private methods

    private fun getPluginParamByKey(key: String): String {
        if (pluginsParamsMap?.containsKey(key) == true)
            return pluginsParamsMap?.get(key).toString()
        return ""
    }

    private suspend fun registerAll(
            tag: MutableList<String>?,
            pushTagRegistrationListener: PushTagRegistrationI?
    ){
        var totalResult = true;
        tag?.forEach {
            val result = register(it)
            totalResult = totalResult && result
        }
        pushTagRegistrationListener?.pushRregistrationTagComplete(PushPluginsType.applicaster, totalResult)
    }

    private suspend fun register(topic: String): Boolean =
            suspendCoroutine { cont ->
                FirebaseMessaging.getInstance().subscribeToTopic(topic).addOnCompleteListener { task ->
                    cont.resume(task.isSuccessful)
                }
            }

    private suspend fun unregisterAll(
            tag: MutableList<String>?,
            pushTagRegistrationListener: PushTagRegistrationI?
    ){
        var totalResult = true;
        tag?.forEach {
            val result = unregister(it)
            totalResult = totalResult && result
        }
        pushTagRegistrationListener?.pushRregistrationTagComplete(PushPluginsType.applicaster, totalResult)
    }

    private suspend fun unregister(topic: String): Boolean =
            suspendCoroutine { cont ->
                FirebaseMessaging.getInstance().unsubscribeFromTopic(topic).addOnCompleteListener { task ->
                    cont.resume(task.isSuccessful)
                }
            }

    //endregion

    @RequiresApi(Build.VERSION_CODES.O)
    private fun ensureChannels(context: Context) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager

        if(null == notificationManager) {
            return
        }

        // create all the custom channels, if any
        var i = 1
        while (true) {
            val channelName: String? = getParamByKey("${ChannelSettings.CHANNEL_NAME_KEY}_$i")
            if (StringUtil.isEmpty(channelName)) {
                break
            }
            val channelId: String? = getParamByKey("${ChannelSettings.CHANNEL_ID_KEY}_$i")
            if (StringUtil.isEmpty(channelId)) {
                break
            }
            val importance: String? = getParamByKey("${ChannelSettings.CHANNEL_IMPORTANCE_KEY}_$i")
            val sound: String? = getParamByKey("${ChannelSettings.CHANNEL_SOUND_KEY}_$i")
            val soundUrl: Uri? = NotificationUtil.getSoundUri(sound, context)
            val channelCompat = NotificationChannel(
                    channelId,
                    channelName,
                    getImportanceId(importance))
            channelCompat.setSound(soundUrl, Notification.AUDIO_ATTRIBUTES_DEFAULT)
            notificationManager.createNotificationChannel(channelCompat)
            ++i
        }

        // create default channel (backward compatibility for plugin settings)
        val sound: String? = getParamByKey(ChannelSettings.CHANNEL_SOUND_KEY)
        val soundUrl: Uri? = NotificationUtil.getSoundUri(sound, context)

        val paramChannelName = getParamByKey(CHANNEL_NAME_KEY)
        val channel = NotificationChannel(
                FIREBASE_DEFAULT_CHANNEL_ID,
                if (TextUtils.isEmpty(paramChannelName)) ChannelSettings.DEFAULT_CHANNEL_NAME else paramChannelName,
                NotificationManager.IMPORTANCE_DEFAULT
        )
        channel.setSound(soundUrl, Notification.AUDIO_ATTRIBUTES_DEFAULT)
        notificationManager.createNotificationChannel(channel)
    }

    private fun getImportanceId(importance: String?): Int {
        if (StringUtil.isEmpty(importance)) {
            return NotificationManagerCompat.IMPORTANCE_DEFAULT
        }
        return when (importance!!.toLowerCase(Locale.getDefault())) {
            ChannelSettings.PRIORITY_HIGH -> NotificationManagerCompat.IMPORTANCE_HIGH
            ChannelSettings.PRIORITY_DEFAULT -> NotificationManagerCompat.IMPORTANCE_DEFAULT
            ChannelSettings.PRIORITY_LOW -> NotificationManagerCompat.IMPORTANCE_LOW
            ChannelSettings.PRIORITY_MIN -> NotificationManagerCompat.IMPORTANCE_MIN
            else -> NotificationManagerCompat.IMPORTANCE_DEFAULT
        }
    }

    private fun getParamByKey(key: String): String? {
        return pluginsParamsMap?.get(key) as String?
    }
}
