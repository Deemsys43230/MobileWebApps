package com.deemsysinc.nellaimarts

import android.app.Activity
import android.app.Dialog
import android.os.Bundle
import android.support.v7.widget.DividerItemDecoration
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.View
import android.view.Window
import android.widget.ImageView
import android.widget.Toast
import kotlinx.android.synthetic.main.location_item.*

class CustomListViewDialog(var activity: Activity, internal var adapter: RecyclerView.Adapter<*>) : Dialog(activity),
    View.OnClickListener {
    override fun onClick(v: View?) {
        dismiss()
    }

    var dialog: Dialog? = null


    var cancelImage:ImageView?=null

     var recyclerView: RecyclerView? = null
    private var mLayoutManager: RecyclerView.LayoutManager? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.location_item)
        recyclerView = recycler_view
        cancelImage=cancel
        cancelImage?.setOnClickListener(this)
        recyclerView?.addItemDecoration(DividerItemDecoration(activity, DividerItemDecoration.VERTICAL))
        mLayoutManager = LinearLayoutManager(activity)
        recyclerView?.layoutManager = mLayoutManager
        recyclerView?.adapter = adapter


    }

    }