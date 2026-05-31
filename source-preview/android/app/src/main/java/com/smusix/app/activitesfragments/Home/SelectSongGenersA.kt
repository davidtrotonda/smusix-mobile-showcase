package com.smusix.app.activitesfragments.Home

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.view.ContextThemeWrapper
import androidx.core.content.ContextCompat
import com.google.android.material.chip.Chip
import com.google.android.material.shape.ShapeAppearanceModel
import com.smusix.app.Constants
import com.smusix.app.R
import com.smusix.app.activitesfragments.Home.adapter.GenreCardAdapter
import com.smusix.app.activitesfragments.Home.adapter.SubgenreAdapter
import com.smusix.app.databinding.ActivitySelectSongGenersBinding
import com.smusix.app.interfaces.AdapterClickListener
import com.smusix.app.models.SongGenreModel
import com.smusix.app.models.SubGenreModel
import com.smusix.app.simpleclasses.ApiRepository
import com.smusix.app.simpleclasses.Functions
import com.smusix.app.simpleclasses.Variables
import com.volley.plus.interfaces.APICallBack
import com.yuyakaido.android.cardstackview.CardStackLayoutManager
import com.yuyakaido.android.cardstackview.CardStackListener
import com.yuyakaido.android.cardstackview.Direction
import com.yuyakaido.android.cardstackview.StackFrom
import kotlin.random.Random

class SelectSongGenersA : AppCompatActivity(),CardStackListener {

    lateinit var binding: ActivitySelectSongGenersBinding
    var adapter : GenreCardAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding=ActivitySelectSongGenersBinding.inflate(layoutInflater)
        setContentView(binding.root)

        manager = CardStackLayoutManager(this, this)
        callApi()
    }


    var genreList: ArrayList<SongGenreModel> = ArrayList()

    private fun callApi() {
        Functions.showLoader(this@SelectSongGenersA,false,false)
        ApiRepository.callApiShowGenre(this@SelectSongGenersA, object : APICallBack {
            override fun arrayData(p0: java.util.ArrayList<*>?) {
                Functions.cancelLoader()
               val list=p0 as ArrayList<SongGenreModel>
                addAllGenre(list)
                genreList.addAll(list)

                setChips(genreList)
                setCards()
            }

            override fun onSuccess(p0: String?) {
                Functions.cancelLoader()
            }

            override fun onFail(p0: String?) {
                Functions.cancelLoader()
            }
        })
    }

    fun addAllGenre(list:ArrayList<SongGenreModel> ) {
        val model= SongGenreModel()
        model.id="0"
        for (i in list.indices.reversed()) {
            val item = list[i]
            if (item.homeModel != null) {
                model.homeModel = item.homeModel
                break
            }
        }
        model.title=Functions.getAllType(this)
        model.parent_id="0"
        model.created="0"
        model.children=ArrayList<SubGenreModel>()

        genreList.add(model)


    }

    private lateinit var manager: CardStackLayoutManager

    fun setCards(){
        manager.setStackFrom(StackFrom.Left)
        manager.setVisibleCount(3)
        manager.setTranslationInterval(20.0f)
        manager.setScaleInterval(0.8f)
        manager.setSwipeThreshold(0.3f)
        manager.setMaxDegree(90.0f)
        manager.setDirections(Direction.HORIZONTAL)
        manager.setCanScrollVertical(false)
        manager.setCanScrollHorizontal(true)

        binding.cardViewstack.layoutManager = manager
        adapter = GenreCardAdapter(
            genreList,
            object : AdapterClickListener{
                override fun onItemClick(view: View?, pos: Int, `object`: Any?) {
                    selectGenere(false,0)
                }

            }
        )
        binding.cardViewstack.adapter = adapter

    }


    val mainChipsList=ArrayList<Chip>()
    fun setChips(genreList: ArrayList<SongGenreModel>) {
        binding.chipGroup.removeAllViews()
        mainChipsList.clear()
        for ((index,genre) in genreList!!.withIndex()) {
            val chip = Chip(ContextThemeWrapper(
                binding.chipGroup.context,
                R.style.CustomChipTheme
            )).apply {
                text = genre.title
                isCloseIconVisible = false
                isClickable = true
                isCheckable = false
                setChipBackgroundColorResource(R.color.darkgray)
                setTextColor(ContextCompat.getColor(context, R.color.white))
                textSize = 13f
                textAlignment = View.TEXT_ALIGNMENT_CENTER
                shapeAppearanceModel = ShapeAppearanceModel.Builder()
                    .setAllCornerSizes(10f)
                    .build()
            }
            mainChipsList.add(chip)

            chip.setOnClickListener {
                manager.topPosition=index
                adapter?.notifyItemChanged(0)

                selectChip(index)
                setChildChips(genre)
            }
            if(index==0){
                setChildChips(genre)
            }
            binding.chipGroup.addView(chip) // Add chip to ChipGroup
        }
        binding.exploreAllTitle.visibility=View.VISIBLE
    }



    fun selectChip(position:Int){
        for ((index,chip)  in mainChipsList.withIndex()) {
            if(position==index){
                chip.setChipBackgroundColorResource(R.color.black3)
            }
            else{
                chip.setChipBackgroundColorResource(R.color.darkgray)
            }
        }
    }


    var subGenreAdapter : SubgenreAdapter? = null
    fun setChildChips(model: SongGenreModel) {
        if(model.children.isEmpty()){
            binding.subGenersTitle.visibility=View.GONE
        }
        else{
            binding.subGenersTitle.visibility=View.VISIBLE
            binding.subGenersTitle.text= getString(R.string.or_select_a_subgenre_of, model.title)
        }
        subGenreAdapter = SubgenreAdapter(model.children,object : AdapterClickListener{
            override fun onItemClick(view: View?, pos: Int, `object`: Any?) {
                selectGenere(true,pos)
            }

        })
        binding.recyclerview.adapter = subGenreAdapter
    }


    fun selectGenere(isChild:Boolean,childPosition:Int){
        val edit = Functions.getSettingsPreference(this@SelectSongGenersA).edit()
        if(isChild){
            edit.putString(Variables.ApiGenereID, genreList.get(manager.topPosition).children.get(childPosition).id)
            edit.putString(Variables.ApiGenereName, genreList.get(manager.topPosition).children.get(childPosition).title)
        }
        else {
            edit.putString(Variables.ApiGenereID, genreList.get(manager.topPosition).id)
            edit.putString(Variables.ApiGenereName, genreList.get(manager.topPosition).title)
        }
        edit.commit()
        setResult(RESULT_OK, Intent())
        finish()
    }



    override fun onCardDragging(direction: Direction?, ratio: Float) {
    }

    override fun onCardSwiped(direction: Direction?) {
        if (manager.getTopPosition() == adapter?.getItemCount()) {
            adapter?.notifyDataSetChanged()
            val item = genreList.get(0)
            setChildChips(item)
            selectChip(0)
        }
        else {
            val position: Int = manager.getTopPosition()
            val item = genreList.get(position)
            setChildChips(item)
            selectChip(position)
       }

    }

    override fun onCardRewound() {
    }

    override fun onCardCanceled() {
    }

    override fun onCardAppeared(view: View?, position: Int) {
    }

    override fun onCardDisappeared(view: View?, position: Int) {
    }


}