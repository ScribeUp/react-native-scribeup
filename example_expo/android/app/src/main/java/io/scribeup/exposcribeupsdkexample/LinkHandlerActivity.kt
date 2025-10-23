package io.scribeup.exposcribeupsdkexample

import android.app.Activity
import android.os.Bundle

/**
 * Handles https://scribeup.io/example_expo/open App Links and forwards them to MainActivity
 * without closing any Custom Tab that may be open.
 *
 * - No history / no recents
 * - Immediately finishes after starting MainActivity
 */
class LinkHandlerActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (isTaskRoot()) {
            // App wasn't running: start MainActivity with the original VIEW intent (data/extras preserved)
            val mainIntent = intent
            mainIntent.setClass(this, MainActivity::class.java)
            startActivity(mainIntent)
            finish()
        } else {
            // App already running: just finish so user lands in current task; keeps Custom Tabs open
            finish()
        }
    }
}
