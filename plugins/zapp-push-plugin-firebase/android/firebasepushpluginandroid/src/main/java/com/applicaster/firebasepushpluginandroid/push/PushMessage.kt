package com.applicaster.firebasepushpluginandroid.push

import android.net.Uri

data class PushMessage(
    var body: String = "",
    var bodyLocalizationArgs: Array<String> = arrayOf(),
    var bodyLocalizationKey: Array<String> = arrayOf(),
    var clickAction: String = "",
    var color: String = "",
    var icon: String = "",
    var deepLink: Uri? = Uri.EMPTY,
    var sound: String = "",
    var tag: String = "",
    var title: String = "",
    var titleLocalizationArgs: Array<String> = arrayOf(),
    var titleLocalizationKey: Array<String> = arrayOf(),
    var description: String = "",
    var contentText: String = "",
    var messageId: String = ""
    ) {

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as PushMessage

        if (!bodyLocalizationArgs.contentEquals(other.bodyLocalizationArgs)) return false
        if (!bodyLocalizationKey.contentEquals(other.bodyLocalizationKey)) return false
        if (!titleLocalizationArgs.contentEquals(other.titleLocalizationArgs)) return false
        if (!titleLocalizationKey.contentEquals(other.titleLocalizationKey)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = bodyLocalizationArgs.contentHashCode()
        result = 31 * result + bodyLocalizationKey.contentHashCode()
        result = 31 * result + titleLocalizationArgs.contentHashCode()
        result = 31 * result + titleLocalizationKey.contentHashCode()
        return result
    }

}
