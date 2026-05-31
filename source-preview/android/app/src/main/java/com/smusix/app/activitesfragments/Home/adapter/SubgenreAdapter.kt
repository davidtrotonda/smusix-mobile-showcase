package com.smusix.app.activitesfragments.Home.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.smusix.app.R
import com.smusix.app.databinding.SubgenreItemsBinding
import com.smusix.app.interfaces.AdapterClickListener
import com.smusix.app.models.SubGenreModel

class SubgenreAdapter(
    private val mlist : ArrayList<SubGenreModel>,
    private val listener : AdapterClickListener
) : RecyclerView.Adapter<SubgenreAdapter.MyViewHolder>(){
    inner class MyViewHolder(val binding :SubgenreItemsBinding) : RecyclerView.ViewHolder(binding.root){


    }
    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): MyViewHolder {
        val binding = SubgenreItemsBinding.inflate(LayoutInflater.from(parent.context),parent,false)
        return MyViewHolder(binding)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val item = mlist[position]
        holder.binding.subgenre.text = item.title
        val pos = holder.bindingAdapterPosition
        val backgroundResId = backgrounds[pos % backgrounds.size]
        holder.binding.backgroundImg.setBackgroundResource(backgroundResId)
        holder.itemView.setOnClickListener {
            listener.onItemClick(it,position,item)
        }
    }

    val backgrounds = listOf(
        R.drawable.bg1,
        R.drawable.bg2,
        R.drawable.bg3,
        R.drawable.bg4,
        R.drawable.bg5,
        R.drawable.bg6
    )

    override fun getItemCount(): Int {
        return mlist.size
    }
}