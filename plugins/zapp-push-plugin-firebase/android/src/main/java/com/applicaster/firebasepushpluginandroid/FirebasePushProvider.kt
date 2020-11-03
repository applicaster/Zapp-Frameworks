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
import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.plugin_manager.delayedplugin.DelayedPlugin
import com.applicaster.plugin_manager.push_plugin.PushContract
import com.applicaster.plugin_manager.push_plugin.helper.PushPluginsType
import com.applicaster.plugin_manager.push_plugin.listeners.PushTagLoadedI
import com.applicaster.plugin_manager.push_plugin.listeners.PushTagRegistrationI
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.StringUtil
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine


class FirebasePushProvider : PushContract, DelayedPlugin, GenericPluginI {

    private val TAG = FirebasePushProvider::class.java.simpleName

    private var pluginsParamsMap: MutableMap<*, *>? = null

    private val channelSounds = mutableMapOf<String, Uri>()
    private val channels = mutableSetOf<String>()

    private var isInitialized = false

    override fun initPushProvider(context: Context) {

        if(isInitialized) {
            return
        }
        FirebaseMessaging.getInstance().token
                .addOnCompleteListener {
                    if (!it.isSuccessful) {
                        APLogger.error(TAG, "getToken failed", it.exception)
                    } else {
                        val token = it.result
                        APLogger.info(TAG, "Firebase token $token")
                    }
                }

        if (Build.VERSION.SDK_INT >= 26) {
            ensureChannels(context)
        }
        buildSoundLookup(context)
        // mark as initialized even if there is no token, since its plugin state
        isInitialized = true
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
        // old PushContract way to deliver plugin options
        pluginsParamsMap = params
    }

    override fun setPluginModel(plugin: Plugin) {
        // new generic way to deliver plugin options
        pluginsParamsMap = plugin.configuration
        if(!isInitialized) {
            // happens if plugin was enabled later
            initPushProvider(AppContext.get())
        }
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

        val paramChannelName = getParamByKey(ChannelSettings.CHANNEL_NAME_KEY)
        val channel = NotificationChannel(
                FIREBASE_DEFAULT_CHANNEL_ID,
                if (TextUtils.isEmpty(paramChannelName)) ChannelSettings.DEFAULT_CHANNEL_NAME else paramChannelName,
                NotificationManager.IMPORTANCE_DEFAULT
        )
        channel.setSound(soundUrl, Notification.AUDIO_ATTRIBUTES_DEFAULT)
        notificationManager.createNotificationChannel(channel)
    }


    private fun buildSoundLookup(context: Context) {
        // Build sound lookup table channels for Android before 8
        // Also registers all known channels for verification
        var i = 1
        while (true) {
            val channelId = getParamByKey("${ChannelSettings.CHANNEL_ID_KEY}_$i")
            if (StringUtil.isEmpty(channelId)) {
                break
            }
            channels.add(channelId!!)
            val sound = getParamByKey("${ChannelSettings.CHANNEL_SOUND_KEY}_$i")
            val soundUrl: Uri? = NotificationUtil.getSoundUri(sound, context)
            if (soundUrl != null) {
                channelSounds[channelId] = soundUrl
            }
            ++i
        }
        // Default channel
        val sound = getParamByKey(ChannelSettings.CHANNEL_SOUND_KEY)
        val soundUrl: Uri? = NotificationUtil.getSoundUri(sound, context)
        if (null != soundUrl) {
            channelSounds[FIREBASE_DEFAULT_CHANNEL_ID] = soundUrl
        }
        channels.add(FIREBASE_DEFAULT_CHANNEL_ID)
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

    fun validateChannel(channelId: String): String {
        return when (channelId) {
            in channels -> channelId
            else -> {
                APLogger.error(TAG, "Channel $channelId is not registered, default will be used")
                FIREBASE_DEFAULT_CHANNEL_ID
            }
        }
    }

    fun getSoundForChannel(channel: String) : Uri? = channelSounds[channel]

    companion object {
        fun getInstance(): FirebasePushProvider? {
            val plugin = PluginManager.getInstance().getInitiatedPlugin(PLUGIN_ID)
            return plugin?.instance as? FirebasePushProvider
        }
    }

    override fun disable(): Boolean {
        FirebaseMessaging.getInstance().deleteToken()
                .addOnSuccessListener {
                    APLogger.info(TAG, "Firebase push token was deleted")
                }.addOnFailureListener {
                    APLogger.error(TAG, "Failed to delete Firebase push token")
                }
        isInitialized = false // plugin is now not initialized in any case
        return true
    }

}
