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
import com.applicaster.storage.LocalStorage
import com.applicaster.util.APLogger
import com.applicaster.util.AppContext
import com.applicaster.util.AppData
import com.applicaster.util.StringUtil
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.*
import kotlin.collections.ArrayList
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine


class FirebasePushProvider : PushContract, DelayedPlugin, GenericPluginI {

    private var pluginsParamsMap: MutableMap<*, *>? = null

    private val channelSounds = mutableMapOf<String, Uri>()
    private val channels = mutableSetOf<String>()

    private var isInitialized = false

    // all registered topics
    private val topics = mutableSetOf<String>()

    // default topics that we register and control automatically
    private val ownedTopics = mutableSetOf<String>()

    override fun initPushProvider(context: Context) {

        if(isInitialized) {
            return
        }

        val stored = LocalStorage.get(localStorageTopicsParam, pluginId)
        if (!stored.isNullOrEmpty()) {
            topics.addAll(stored.split(","))
        }

        val defStored = LocalStorage.get(localStorageOwnedTopicsParam, pluginId)
        if (!defStored.isNullOrEmpty()) {
            ownedTopics.addAll(defStored.split(","))
        }

        // this call is required since we've disabled auto-init in the manifest
        FirebaseMessaging.getInstance().token
                .addOnCompleteListener {
                    if (!it.isSuccessful) {
                        APLogger.error(Companion.TAG, "getToken failed", it.exception)
                    } else {
                        val token = it.result
                        APLogger.info(Companion.TAG, "Firebase push token $token")
                        GlobalScope.launch ( Dispatchers.Main ) {
                            registerDefaultTopics()
                        }
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
            registerAll(tag!!, pushTagRegistrationListener)
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
        if(pluginId != plugin.identifier) {
            APLogger.error(Companion.TAG, "Plugin id mismatch: $pluginId expected, ${plugin.identifier} received")
        }
    }

    override fun getTagList(context: Context?, listener: PushTagLoadedI?) {
        listener?.tagLoaded(pluginType, ArrayList(topics))
    }

    override fun setPushEnabled(context: Context?, isEnabled: Boolean) {
        val componentName = ComponentName(context!!, APMessagingService::class.java)
        context.packageManager.setComponentEnabledSetting(componentName,
                if (isEnabled) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP)
        APLogger.info(Companion.TAG, "Firebase push receiver is now ${if (isEnabled) "enabled" else "disabled"}")
    }

    //region Private methods

    private fun getPluginParamByKey(key: String): String {
        if (pluginsParamsMap?.containsKey(key) == true)
            return pluginsParamsMap?.get(key).toString()
        return ""
    }

    private suspend fun registerAll(
            tag: List<String>,
            pushTagRegistrationListener: PushTagRegistrationI?
    ): Boolean {
        var totalResult = true;
        tag.forEach {
            val result = register(it)
            totalResult = totalResult && result
        }
        pushTagRegistrationListener?.pushRregistrationTagComplete(PushPluginsType.applicaster, totalResult)
        return totalResult
    }

    private suspend fun register(topic: String): Boolean =
            suspendCoroutine { cont ->
                FirebaseMessaging.getInstance().subscribeToTopic(topic).addOnCompleteListener { task ->
                    if(task.isSuccessful) {
                        topics.add(topic)
                        storeTopics()
                    } else {
                        APLogger.error(TAG, "Failed to subscribe to topic $topic", task.exception)
                    }
                    cont.resume(task.isSuccessful)
                }
            }

    private suspend fun unregisterAll(
            tag: MutableList<String>?,
            pushTagRegistrationListener: PushTagRegistrationI?
    ): Boolean {
        var totalResult = true;
        tag?.forEach {
            val result = unregister(it)
            totalResult = totalResult && result
        }
        pushTagRegistrationListener?.pushRregistrationTagComplete(PushPluginsType.applicaster, totalResult)
        return totalResult
    }

    private suspend fun unregister(topic: String): Boolean =
            suspendCoroutine { cont ->
                FirebaseMessaging.getInstance().unsubscribeFromTopic(topic).addOnCompleteListener { task ->
                    if(task.isSuccessful) {
                        topics.remove(topic)
                        storeTopics()
                    } else {
                        APLogger.error(TAG, "Failed to unsubscribe from topic $topic", task.exception)
                    }
                    cont.resume(task.isSuccessful)
                }
            }

    private suspend fun registerDefaultTopics() {
        val defaultTopics = getPluginParamByKey(defaultTopicKey)
        val defaultLocTopics = getPluginParamByKey(defaultLocalizedTopics)

        val allTopics = mutableSetOf<String>()

        if (!TextUtils.isEmpty(defaultTopics)) {
            val defTopics = defaultTopics
                    .split(",")
                    .map { it.trim().toLowerCase(Locale.ENGLISH) }
                    .filter { it.isNotEmpty() }
            allTopics.addAll(defTopics)
        }

        if(!TextUtils.isEmpty(defaultLocTopics)) {
            val language = AppData.getLocale().language
            val locTopics = defaultLocTopics
                    .split(",")
                    .map { it.trim().toLowerCase(Locale.ENGLISH) }
                    .filter { it.isNotEmpty() }
                    .map { "$it-$language" }
            allTopics.addAll(locTopics)
        }

        val toRemove = ownedTopics - allTopics
        val toAdd = allTopics - ownedTopics

        APLogger.info(TAG, "Unregistering default topics: $toRemove")
        toRemove.forEach {
            if(unregister(it)) { // has error message inside
                ownedTopics.remove(it)
            }
        }
        APLogger.info(TAG, "Registering default topics: $toAdd")
        toAdd.forEach {
            if(register(it)) {  // has error message inside
                ownedTopics.add(it)
            }
        }
        // needed to store latest ownedTopics update
        LocalStorage.set(localStorageOwnedTopicsParam, ownedTopics.joinToString ( "," ), pluginId)
    }

    private fun storeTopics() {
        LocalStorage.set(localStorageTopicsParam, topics.joinToString ( "," ), pluginId)
        LocalStorage.set(localStorageOwnedTopicsParam, ownedTopics.joinToString ( "," ), pluginId)
    }

    //endregion

    @RequiresApi(Build.VERSION_CODES.O)
    private fun ensureChannels(context: Context) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return

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
                APLogger.error(Companion.TAG, "Channel $channelId is not registered, default will be used")
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
        private const val TAG = "FirebasePushProvider"
        private const val defaultTopicKey = "default_topic"
        private const val defaultLocalizedTopics = "default_localized_topics"
        private const val localStorageTopicsParam = "topics"
        private const val localStorageOwnedTopicsParam = "defaultTopics"
        // this field is available in Plugin model now, but for now we keep a copy and check it
        const val pluginId = "ZappPushPluginFirebase"
    }

    override fun disable(): Boolean {
        FirebaseMessaging.getInstance().deleteToken()
                .addOnSuccessListener {
                    APLogger.info(Companion.TAG, "Firebase push token was deleted")
                }.addOnFailureListener {
                    APLogger.error(Companion.TAG, "Failed to delete Firebase push token")
                }
        LocalStorage.remove(localStorageTopicsParam, pluginId)
        isInitialized = false // plugin is now not initialized in any case
        return true
    }

}
