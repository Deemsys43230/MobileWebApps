package com.deemsysinc.nellaimarts;

import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView

import kotlinx.android.synthetic.main.location_layout.view.*
import org.json.JSONObject

class DataAdapter(
private val mDataset: MutableList<Any>,
        internal var recyclerViewItemClickListener: RecyclerViewItemClickListener
) : RecyclerView.Adapter<DataAdapter.MyViewHolder>() {

        override fun onCreateViewHolder(parent: ViewGroup, i: Int): MyViewHolder {

        val v = LayoutInflater.from(parent.context).inflate(R.layout.location_layout, parent, false)

        return MyViewHolder(v)

        }

        override fun onBindViewHolder(locationViewHolder: MyViewHolder, i: Int) {
         var anyObject:Any
        anyObject=   mDataset.get(i)
        var converString:String=anyObject.toString()
        var jsonObject:JSONObject= JSONObject(converString)

        locationViewHolder.mTextView.text = jsonObject.getString("location")

        }

        override fun getItemCount(): Int {
        return mDataset.size
        }


        inner class MyViewHolder(v: View) : RecyclerView.ViewHolder(v), View.OnClickListener {

        var mTextView: TextView

        init {
            mTextView = v.text
            v.setOnClickListener(this)
        }

        override fun onClick(v: View) {
            recyclerViewItemClickListener.clickOnItem(this.adapterPosition)

            }
        }

    interface RecyclerViewItemClickListener {
        fun clickOnItem(index:Int)
    }
}




