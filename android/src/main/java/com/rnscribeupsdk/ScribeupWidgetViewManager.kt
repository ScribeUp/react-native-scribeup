package com.rnscribeupsdk

import android.view.View
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import io.scribeup.scribeupsdk.ui.SubscriptionManagerWidgetView

class ScribeupWidgetViewManager(private val reactContext: ReactApplicationContext) : SimpleViewManager<SubscriptionManagerWidgetView>() {

    companion object {
        const val REACT_CLASS = "ScribeupWidgetView"
        const val COMMAND_RELOAD = 1
        const val COMMAND_LOAD_URL = 2
    }

    override fun getName(): String {
        return REACT_CLASS
    }

    override fun createViewInstance(reactContext: ThemedReactContext): SubscriptionManagerWidgetView {
        return SubscriptionManagerWidgetView(reactContext)
    }

    @ReactProp(name = "url")
    fun setUrl(view: SubscriptionManagerWidgetView, url: String?) {
        if (!url.isNullOrEmpty()) {
            view.loadURL(url)
        }
    }

    override fun getCommandsMap(): Map<String, Int>? {
        return MapBuilder.of(
            "reload", COMMAND_RELOAD,
            "loadURL", COMMAND_LOAD_URL
        )
    }

    override fun receiveCommand(
        root: SubscriptionManagerWidgetView,
        commandId: String?,
        args: ReadableArray?
    ) {
        super.receiveCommand(root, commandId, args)
        
        when (commandId?.toIntOrNull()) {
            COMMAND_RELOAD -> {
                root.reload()
            }
            COMMAND_LOAD_URL -> {
                if (args != null && args.size() > 0) {
                    val url = args.getString(0)
                    if (!url.isNullOrEmpty()) {
                        root.loadURL(url)
                    }
                }
            }
        }
    }

    override fun receiveCommand(
        root: SubscriptionManagerWidgetView,
        commandId: Int,
        args: ReadableArray?
    ) {
        when (commandId) {
            COMMAND_RELOAD -> {
                root.reload()
            }
            COMMAND_LOAD_URL -> {
                if (args != null && args.size() > 0) {
                    val url = args.getString(0)
                    if (!url.isNullOrEmpty()) {
                        root.loadURL(url)
                    }
                }
            }
        }
    }
}