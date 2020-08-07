package com.applicaster.plugin.xray.ui

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
    }
}
