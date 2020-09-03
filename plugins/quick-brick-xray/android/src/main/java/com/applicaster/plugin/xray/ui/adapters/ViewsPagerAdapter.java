package com.applicaster.plugin.xray.ui.adapters;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.PagerTitleStrip;
import androidx.viewpager.widget.ViewPager;

import com.applicaster.plugin.xray.R;

/**
 * Created by ink on 2017-05-08.
 *
 * Hacky class to use child views in PagerAdapter
 */
public class ViewsPagerAdapter extends PagerAdapter {
    private final int mOffset; // if > 0, first view is PagerTitleStrip
    private ViewPager mPager;

    public ViewsPagerAdapter(ViewPager pager) {
        mPager = pager;
        mOffset = mPager.getChildAt(0) instanceof PagerTitleStrip ? 1 : 0;
        mPager.setOffscreenPageLimit(mPager.getChildCount() - mOffset);
    }

    public Object instantiateItem(ViewGroup collection, int position) {
        return collection.getChildAt(position + mOffset);
    }

    @Nullable
    @Override
    public CharSequence getPageTitle(int position) {
        View child = mPager.getChildAt(position + mOffset);
        return (CharSequence) child.getTag(R.id.fragment_title_tag);
    }

    @Override
    public int getCount() {
        return mPager.getChildCount() - mOffset;
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
