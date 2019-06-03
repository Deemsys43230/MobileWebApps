package com.deemsysinc.shoppickk.Utils

import android.app.Activity
import android.content.Context
import android.support.v4.content.ContextCompat
import android.view.WindowManager
import com.deemsysinc.shoppickk.R

class utilityClass {
   lateinit var context:Activity
    constructor(context:Activity){
        this.context = context
    }

    fun StatusBarColor(){
        var window = context.getWindow()
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.setStatusBarColor(ContextCompat.getColor(context, R.color.colorsplash))
    }
}