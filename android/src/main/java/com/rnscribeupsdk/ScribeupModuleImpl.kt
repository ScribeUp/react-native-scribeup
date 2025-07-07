package com.rnscribeupsdk

import android.app.Activity
import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import io.scribeup.scribeupsdk.SubscriptionManager
import io.scribeup.scribeupsdk.SubscriptionManagerListener
import io.scribeup.scribeupsdk.data.models.SubscriptionManagerError
import android.webkit.URLUtil
import java.net.URL

// Error codes shared between iOS and Android
object ErrorCodes {
  const val UNKNOWN = -1
  const val INVALID_URL = 1001
  const val ACTIVITY_NULL = 1002
  const val INVALID_ACTIVITY_TYPE = 1003
  const val NO_ROOT_VIEW_CONTROLLER = 1004
  const val SDK_ERROR = 2001
}

class ScribeupModuleImpl(private val reactContext: ReactApplicationContext) {

  private var exitCallback: ((SubscriptionManagerError?) -> Unit)? = null

  fun setExitCallback(callback: (SubscriptionManagerError?) -> Unit) {
    this.exitCallback = callback
  }

  fun present(url: String, productName: String) {
    val activity: Activity? = reactContext.currentActivity

    // Check for null activity
    if (activity == null) {
      Log.e("Scribeup", "Activity is null")
      val error = SubscriptionManagerError(message = "Activity is null", code = ErrorCodes.ACTIVITY_NULL)
      exitCallback?.invoke(error)
      return
    }

    // Check if activity is FragmentActivity
    if (activity !is FragmentActivity) {
      Log.e("Scribeup", "Activity is not a FragmentActivity")
      val error = SubscriptionManagerError(message = "Activity is not a FragmentActivity", code = ErrorCodes.INVALID_ACTIVITY_TYPE)
      exitCallback?.invoke(error)
      return
    }

    // Validate the URL before proceeding
    if (!isValidUrl(url)) {
      Log.e("Scribeup", "Invalid URL: $url")
      val error = SubscriptionManagerError(message = "Invalid URL: $url", code = ErrorCodes.INVALID_URL)
      exitCallback?.invoke(error)
      return
    }

    try {
      SubscriptionManager.present(
        host = activity as FragmentActivity,
        url = url,
        productName = productName,
        listener = object : SubscriptionManagerListener {
          override fun onExit(error: SubscriptionManagerError?) {
            val params = Arguments.createMap()

            if (error != null) {
              params.putString("message", error.message)
              params.putInt("code", error.code)
            }

            exitCallback?.invoke(error)
          }
        }
      )
    } catch (e: Exception) {
      Log.e("Scribeup", "Error presenting subscription manager: ${e.message}")
      val error = SubscriptionManagerError(message = e.message ?: "Unknown error", code = ErrorCodes.UNKNOWN)
      exitCallback?.invoke(error)
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

        val newParams = Arguments.createMap()
        if (params != null) {
          if (params.hasKey("message")) {
            newParams.putString("message", params.getString("message"))
          }
          if (params.hasKey("code")) {
            newParams.putString("code", params.getString("code"))
          }
        }

        eventEmitter.emit("ScribeupExitSignal", newParams)
      } catch (e: Exception) {
        Log.e("Scribeup", "Error emitting event: ${e.message}")
      }
    }
  }
}
