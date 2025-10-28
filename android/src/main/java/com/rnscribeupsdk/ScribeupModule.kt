package com.rnscribeupsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import android.util.Log
import com.facebook.react.bridge.Arguments

@ReactModule(name = ScribeupModule.NAME)
class ScribeupModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  companion object {
    const val NAME = "Scribeup"
  }

  private val moduleImpl = ScribeupModuleImpl(reactContext)
  private var hasExited = false
  private var currentPromise: Promise? = null

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun checkExitStatus(promise: Promise) {
    val map = Arguments.createMap()
    map.putBoolean("hasExited", hasExited)
    promise.resolve(map)
  }

  @ReactMethod
  fun presentWithUrl(url: String, productName: String, enableBackButton: Boolean, promise: Promise) {
    try {
      currentPromise = promise
      moduleImpl.present(url, productName, enableBackButton)
      moduleImpl.setExitCallback { error ->
        hasExited = true
        if (error != null) {
          val params = Arguments.createMap()
          params.putString("message", error.message)
          params.putInt("code", error.code)
          currentPromise?.resolve(params)
        } else {
          currentPromise?.resolve(null)
        }
        currentPromise = null
      }
    } catch (e: Exception) {
      val params = Arguments.createMap()
      params.putString("message", e.message ?: "Unexpected Error")
      params.putInt("code", 1000)
      promise.resolve(params)
      currentPromise = null
    }
  }

}
