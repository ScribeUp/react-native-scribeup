package com.rnscribeupsdk

import android.app.Activity
import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import io.scribeup.scribeupsdk.SubscriptionManager
import io.scribeup.scribeupsdk.SubscriptionManagerListener
import io.scribeup.scribeupsdk.data.models.SubscriptionManagerError
import android.webkit.URLUtil
import java.net.URL

// Error codes shared between iOS and Android
object ErrorCodes {
  const val UNKNOWN = 1000
  const val INVALID_URL = 1001
  const val INVALID_ENV = 1002
  const val ACTIVITY_NULL = 1003
  const val INVALID_ACTIVITY_TYPE = 1004
  const val NO_ROOT_VIEW_CONTROLLER = 1005
}

class ScribeupModuleImpl(private val reactContext: ReactApplicationContext) {

  private var exitCallback: ((SubscriptionManagerError?) -> Unit)? = null

  fun setExitCallback(callback: (SubscriptionManagerError?) -> Unit) {
    this.exitCallback = callback
  }

  fun present(url: String, productName: String, enableBackButton: Boolean) {
    val activity: Activity? = reactContext.currentActivity

    // Check for null activity
    if (activity == null) {
      Log.e("Scribeup", "Activity is null")
      val error = SubscriptionManagerError(message = "Activity is null", code = ErrorCodes.ACTIVITY_NULL)
      val params = Arguments.createMap().apply {
        putMap("error", Arguments.createMap().apply {
          putInt("code", error.code)
          putString("message", error.message)
        })
      }
      sendEvent("ScribeupOnExit", params)
      return
    }

    // Check if activity is FragmentActivity
    if (activity !is FragmentActivity) {
      Log.e("Scribeup", "Activity is not a FragmentActivity")
      val error = SubscriptionManagerError(message = "Activity is not a FragmentActivity", code = ErrorCodes.INVALID_ACTIVITY_TYPE)
      val params = Arguments.createMap().apply {
        putMap("error", Arguments.createMap().apply {
          putInt("code", error.code)
          putString("message", error.message)
        })
      }
      sendEvent("ScribeupOnExit", params)
      return
    }

    // Validate the URL before proceeding
    if (!isValidUrl(url)) {
      Log.e("Scribeup", "Invalid URL: $url")
      val error = SubscriptionManagerError(message = "Invalid URL: $url", code = ErrorCodes.INVALID_URL)
      val params = Arguments.createMap().apply {
        putMap("error", Arguments.createMap().apply {
          putInt("code", error.code)
          putString("message", error.message)
        })
      }
      sendEvent("ScribeupOnExit", params)
      return
    }

    try {
      SubscriptionManager.present(
        host = activity as FragmentActivity,
        url = url,
        productName = productName,
        listener = object : SubscriptionManagerListener {
          override fun onExit(error: SubscriptionManagerError?, data: Map<String, Any?>?) {
            val params = Arguments.createMap()

            if (error != null) {
              params.putMap("error", Arguments.createMap().apply {
                putInt("code", error.code)
                putString("message", error.message)
              })
            }

            if (data != null) {
              params.putMap("data", toWritableMap(data))
            }

            sendEvent("ScribeupOnExit", params)
          }

          override fun onEvent(data: Map<String, Any?>) {
            val params = Arguments.createMap().apply {
              putMap("data", toWritableMap(data))
            }
            sendEvent("ScribeupOnEvent", params)
          }
        },
        enableBackButton = enableBackButton
      )
    } catch (e: Exception) {
      Log.e("Scribeup", "Error presenting subscription manager: ${e.message}")
      val error = SubscriptionManagerError(message = e.message ?: "Unexpected Error", code = ErrorCodes.UNKNOWN)
      val params = Arguments.createMap().apply {
        putMap("error", Arguments.createMap().apply {
          putInt("code", error.code)
          putString("message", error.message)
        })
      }
      sendEvent("ScribeupOnExit", params)
    }
  }

  // Helper method to validate URLs
  private fun isValidUrl(urlString: String): Boolean {
    return try {
      val url = URL(urlString)
      URLUtil.isValidUrl(urlString) && (url.protocol == "http" || url.protocol == "https")
    } catch (e: Exception) {
      false
    }
  }

  fun sendEvent(eventName: String, params: WritableMap?) {
    reactContext.runOnUiQueueThread {
      try {
        val eventEmitter = reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        eventEmitter.emit(eventName, params ?: Arguments.createMap())
      } catch (e: Exception) {
        Log.e("Scribeup", "Error emitting event: ${e.message}")
      }
    }
  }

  // -------------------- Converters: Map/List -> Writable* --------------------

  @Suppress("UNCHECKED_CAST")
  private fun toWritableMap(map: Map<String, Any?>): WritableMap {
    val out = Arguments.createMap()
    for ((kAny, v) in map) {
      val key = kAny as String
      when (v) {
        null -> out.putNull(key)
        is String -> out.putString(key, v)
        is Int -> out.putInt(key, v)
        is Long -> {
          if (v in Int.MIN_VALUE..Int.MAX_VALUE) out.putInt(key, v.toInt()) else out.putDouble(key, v.toDouble())
        }
        is Float -> out.putDouble(key, v.toDouble())
        is Double -> out.putDouble(key, v)
        is Boolean -> out.putBoolean(key, v)
        is Map<*, *> -> out.putMap(key, toWritableMap(v as Map<String, Any?>))
        is List<*> -> out.putArray(key, toWritableArray(v))
        else -> out.putString(key, v.toString())
      }
    }
    return out
  }

  private fun toWritableArray(list: List<*>): WritableArray {
    val out = Arguments.createArray()
    for (v in list) {
      when (v) {
        null -> out.pushNull()
        is String -> out.pushString(v)
        is Int -> out.pushInt(v)
        is Long -> {
          if (v in Int.MIN_VALUE..Int.MAX_VALUE) out.pushInt(v.toInt()) else out.pushDouble(v.toDouble())
        }
        is Float -> out.pushDouble(v.toDouble())
        is Double -> out.pushDouble(v)
        is Boolean -> out.pushBoolean(v)
        is Map<*, *> -> out.pushMap(toWritableMap(v as Map<String, Any?>))
        is List<*> -> out.pushArray(toWritableArray(v))
        else -> out.pushString(v.toString())
      }
    }
    return out
  }
}
