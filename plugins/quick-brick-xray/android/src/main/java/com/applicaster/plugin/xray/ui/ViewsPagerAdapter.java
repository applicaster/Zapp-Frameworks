package com.applicaster.plugin.xray.ui;

import android.view.View;
import android.view.ViewGroup;

import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

/**
 * Created by ink on 2017-05-08.
 *
 * Hacky class to use child views in PagerAdapter
 */
public class ViewsPagerAdapter extends PagerAdapter {
    private ViewPager mPager;

    public ViewsPagerAdapter(ViewPager pager) {
        mPager = pager;
        mPager.setOffscreenPageLimit(mPager.getChildCount());
    }

    public Object instantiateItem(ViewGroup collection, int position) {
        return collection.getChildAt(position);
    }

    @Override
    public int getCount() {
        return mPager.getChildCount();
    }

    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
        return arg0 == arg1;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
    }

    @Override
    public void destroyItem(View container, int position, Object object) {
    }
}
