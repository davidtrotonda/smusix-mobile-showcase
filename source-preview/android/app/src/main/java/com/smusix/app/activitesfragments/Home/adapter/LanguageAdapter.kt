package com.smusix.app.activitesfragments.Home.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.smusix.app.R
import com.smusix.app.databinding.LanguageItemBinding
import com.smusix.app.interfaces.AdapterClickListener
import com.smusix.app.models.LanguageModel
import com.smusix.app.simpleclasses.Functions

class LanguageAdapter(
    private val mlist : ArrayList<LanguageModel>,
    private val listener : AdapterClickListener
) : RecyclerView.Adapter<LanguageAdapter.MyViewHolder>(){
    inner class MyViewHolder(val binding :LanguageItemBinding) : RecyclerView.ViewHolder(binding.root)
    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): MyViewHolder {
        val binding = LanguageItemBinding.inflate(LayoutInflater.from(parent.context),parent,false)
        return MyViewHolder(binding)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val item = mlist[position]
        holder.binding.languageText.text = Functions.capitalizeFirstLetter(item.title)
        holder.binding.languageText2.text = holder.binding.root.context.getString(R.string.listen_to_music_in) +item.title
        val pos = holder.bindingAdapterPosition
        val backgroundResId = headerImages[pos % headerImages.size]
        val footerId = footerImages[pos % footerImages.size]
        holder.binding.headerImg.setBackgroundResource(backgroundResId)
        holder.binding.footerImg.setBackgroundResource(footerId)

        holder.itemView.setOnClickListener {
            listener.onItemClick(it,holder.bindingAdapterPosition,item)
        }
    }

    val headerImages = listOf(
        R.drawable.lh1,
        R.drawable.lh2,
        R.drawable.lh3,
        R.drawable.lh4,
        R.drawable.lh5,
        R.drawable.lh6
    )
    val footerImages = listOf(
        R.drawable.lf1,
        R.drawable.lf2,
        R.drawable.lf3,
        R.drawable.lf4,
        R.drawable.lf5,
        R.drawable.lf6
    )

    override fun getItemCount(): Int {
        return mlist.size
    }
}