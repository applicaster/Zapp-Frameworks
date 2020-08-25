package com.applicaster.plugin.xray.ui

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager.widget.ViewPager
import com.applicaster.plugin.xray.R
import com.applicaster.plugin.xray.ui.adapters.ViewsPagerAdapter

class LogActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val pager: ViewPager = findViewById(R.id.pager)
        pager.adapter = ViewsPagerAdapter(pager)
        pager.currentItem = 1
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        intent?.data?.let {
            val params= it.queryParameterNames
            for (key in params) {
                val value = it.getQueryParameter(key)
                if(value.isNullOrBlank()){
                    continue
                }
                // todo: update local settings
            }
        }
    }
}
