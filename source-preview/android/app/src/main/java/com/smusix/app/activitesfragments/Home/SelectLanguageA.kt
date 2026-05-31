package com.smusix.app.activitesfragments.Home

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.smusix.app.activitesfragments.Home.adapter.LanguageAdapter
import com.smusix.app.databinding.ActivitySelectLanguageBinding
import com.smusix.app.interfaces.AdapterClickListener
import com.smusix.app.models.LanguageModel
import com.smusix.app.models.SongGenreModel
import com.smusix.app.simpleclasses.ApiRepository
import com.smusix.app.simpleclasses.Functions
import com.smusix.app.simpleclasses.Variables
import com.volley.plus.interfaces.APICallBack
import io.paperdb.Paper

class SelectLanguageA : AppCompatActivity() {
    lateinit var  binding : ActivitySelectLanguageBinding
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySelectLanguageBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val list = Paper.book(Variables.Language).read<ArrayList<LanguageModel>>(Variables.LanguageList)
        if(list!=null) {
            val adapter = LanguageAdapter(list, object : AdapterClickListener {
                override fun onItemClick(view: View?, pos: Int, `object`: Any?) {
                    val item = `object` as LanguageModel
                    val editor = Functions.getSettingsPreference(this@SelectLanguageA).edit()
                    editor.putString(Variables.ApiLevelLanguageId, item.id)
                    editor.putString(Variables.ApiLevelLanguageCode, item.code)

                    editor.putString(Variables.ApiGenereID, "0")
                    editor.putString(
                        Variables.ApiGenereName,
                        Functions.getAllType(this@SelectLanguageA)
                    )
                    editor.commit()

                    val intent = Intent()
                    intent.putExtra("isShow", true)
                    setResult(RESULT_OK, intent)
                    finish()

                }

            })
            binding.recylerView.adapter = adapter
        }

    }



}