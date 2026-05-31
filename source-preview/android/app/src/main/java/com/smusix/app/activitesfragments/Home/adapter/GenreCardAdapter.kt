package com.smusix.app.activitesfragments.Home.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.smusix.app.R
import com.smusix.app.databinding.GenreCardLayBinding
import com.smusix.app.interfaces.AdapterClickListener
import com.smusix.app.models.SongGenreModel
import com.smusix.app.simpleclasses.Functions

class GenreCardAdapter(
    private val items: List<SongGenreModel>,
    private val listener: AdapterClickListener
) : RecyclerView.Adapter<GenreCardAdapter.ViewHolder>() {

    inner class ViewHolder(val binding: GenreCardLayBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: SongGenreModel) {
            binding.text.text = item.title
            if (item.homeModel != null){
                if(item.homeModel.userModel?.getProfilePic()!!.isNotEmpty()) {
                    binding.videoThumbnail.setController(
                        Functions.frescoImageLoad(
                            item.homeModel.userModel?.getProfilePic(),
                            R.drawable.ic_profile_square,
                            binding.videoThumbnail,
                            false
                        )
                    )
                }else{

                    binding.videoThumbnail.setController(
                        Functions.frescoImageLoad(
                            item.homeModel.videoModel?.getThum(),
                            R.drawable.image_placeholder,
                            binding.videoThumbnail,
                            false
                        )
                    )

                }
        }

            binding.cardView.setOnClickListener {
                listener.onItemClick(it,position,item)
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = GenreCardLayBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size
}