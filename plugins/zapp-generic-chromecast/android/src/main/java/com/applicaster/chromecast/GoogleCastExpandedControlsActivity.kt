package com.applicaster.chromecast

import android.view.Menu
import com.google.android.gms.cast.framework.CastButtonFactory
import com.google.android.gms.cast.framework.media.widget.ExpandedControllerActivity
import com.reactnative.googlecast.R

class GoogleCastExpandedControlsActivity : ExpandedControllerActivity() {

    companion object {
        @JvmField
        val EXTRA_TRIGGER = "EXTRA_TRIGGER"
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        super.onCreateOptionsMenu(menu)
        menuInflater.inflate(R.menu.cast_expanded_controller_menu, menu)
        CastButtonFactory.setUpMediaRouteButton(this, menu, R.id.media_route_menu_item)
        return true
    }

    override fun onStart() {
        super.onStart()
        var trigger = intent.extras?.getString(EXTRA_TRIGGER)
        if (null == trigger) {
            trigger = "Notification";
        }
        ChromeCastPlugin.getInstance()?.analytics?.openedChromecastExpandedView(trigger)
    }

    override fun onStop() {
        super.onStop()
        ChromeCastPlugin.getInstance()?.analytics?.closedChromecastExpandedView()
    }
}
