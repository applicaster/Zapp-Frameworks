package com.theoplayerreactnative.utility

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*

object JSON2RN {

    // todo: move to the SDK

    @JvmStatic
    @Throws(JSONException::class)
    fun toMap(jsonObject: JSONObject): Map<String, Any> {
        val map: MutableMap<String, Any> = HashMap()
        val keysItr = jsonObject.keys()
        while (keysItr.hasNext()) {
            val key = keysItr.next()
            var value = jsonObject[key]
            if (value is JSONArray) {
                value = toList(value)
            } else if (value is JSONObject) {
                value = toMap(value)
            }
            map[key] = value
        }
        return map
    }

    @JvmStatic
    @Throws(JSONException::class)
    fun toList(array: JSONArray): List<Any> {
        val list: MutableList<Any> = ArrayList()
        for (i in 0 until array.length()) {
            var value = array[i]
            if (value is JSONArray) {
                value = toList(value)
            } else if (value is JSONObject) {
                value = toMap(value)
            }
            list.add(value)
        }
        return list
    }
}