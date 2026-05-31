package com.smusix.app.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build

import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import com.google.android.gms.tasks.Tasks
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.StorageReference
import com.google.firebase.storage.UploadTask
import com.smusix.app.Constants
import com.smusix.app.R
import com.smusix.app.activitesfragments.Home.HomeF
import com.smusix.app.apiclasses.FileUploader2
import com.smusix.app.models.UploadVideoModel
import com.smusix.app.simpleclasses.DataHolder
import com.smusix.app.simpleclasses.Functions
import com.smusix.app.simpleclasses.SmusixApplication
import com.smusix.app.simpleclasses.Variables
import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject
import java.io.File
import kotlin.coroutines.resume

class VideoUploadWorker(appContext: Context, workerParams: WorkerParameters) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {

        setForeground(createForegroundInfo())

        val storage = FirebaseStorage.getInstance()
        val storageRef: StorageReference = storage.reference

        Functions.printLog(Constants.tag,"firbasestorage:"+storage)


        val bundle= DataHolder.instance?.data

        val videopath = bundle?.getString("uri")
        val videothumb = bundle?.getString("thumb")
        val videoGif = bundle?.getString("gif")
        val draftFile = bundle?.getString("draft_file")
        val uploadModel = bundle?.getParcelable<UploadVideoModel>("data")

        Functions.printLog(Constants.tag,"videopath:"+videopath)
        Functions.printLog(Constants.tag,"videothumb:"+videothumb)
        Functions.printLog(Constants.tag,"videoGif:"+videoGif)

        DataHolder.instance?.data=null

        return try {
            val result = suspendCancellableCoroutine<Result> { continuation ->

                val randomString=Functions.getRandomString(5)

                val videoRef = storageRef.child("videos/"+uploadModel?.userId+"/"+randomString)
                val videothumbRef = storageRef.child("videoThumb/"+uploadModel?.userId+"/"+randomString)
                val videoGifRef =storageRef.child("videoGif/"+uploadModel?.userId+"/"+randomString)

                Functions.printLog(Constants.tag,"videopath:"+videoRef)

                val videoTask = videoRef.putFile(Uri.fromFile(File(videopath)))
                val videothumbTask = videothumbRef.putFile(Uri.fromFile(File(videothumb)))
                val videoGifTask =videoGifRef.putFile(Uri.fromFile(File(videoGif)))

                var totalBytesTransferred: Long = 0
                var totalBytes: Long = 0

                listOf(videoTask, videothumbTask, videoGifTask).forEach { task ->
                    task.addOnProgressListener { snapshot ->
                        totalBytes += snapshot.totalByteCount
                        totalBytesTransferred += snapshot.bytesTransferred

                        val overallProgress = (100.0 * totalBytesTransferred / totalBytes).toInt()

                        val bundle = Bundle().apply {
                            putBoolean("isShow", true)
                            putInt("currentpercent", overallProgress)
                            putInt("totalpercent", 100)
                        }
                        HomeF.uploadingCallback?.onResponce(bundle)

                    }
                }

                Tasks.whenAllSuccess<UploadTask>(videoTask, videothumbTask, videoGifTask)
                    .addOnSuccessListener {

                        val videoUrlTask = videoRef.downloadUrl
                        val videoThumbUrlTask = videothumbRef.downloadUrl
                        val videoGifUrlTask = videoGifRef.downloadUrl

                        Tasks.whenAllSuccess<Uri>(videoUrlTask, videoThumbUrlTask, videoGifUrlTask)
                            .addOnSuccessListener { urls ->
                                uploadModel?.videoUrl = urls[0].toString()
                                uploadModel?.thumbUrl  = urls[1].toString()
                                uploadModel?.gifUrl = urls[2].toString()

                                // Handle the URLs as needed
                                Functions.printLog(Constants.tag,"Video URL: ${uploadModel?.videoUrl}")
                                Functions.printLog(Constants.tag,"Video Thumbnail URL: ${uploadModel?.thumbUrl}")
                                Functions.printLog(Constants.tag,"Video GIF URL: ${uploadModel?.gifUrl}")

                                val fileUploader = FileUploader2( SmusixApplication.appLevelContext!!, uploadModel)
                                fileUploader.SetCallBack(object :
                                    FileUploader2.FileUploaderCallback {
                                    override fun onError() {
                                        Functions.printLog(Constants.tag, "Error")
                                        continuation.resume(Result.failure())
                                        sendBroadByName(Variables.homeBroadCastAction,"Error")
                                        sendBroadByName(Variables.profileBroadCastAction,"Error")
                                    }
                                    override fun onFinish(responses: String) {
                                        Functions.printLog(Constants.tag, responses)
                                        try {
                                            val jsonObject = JSONObject(responses)
                                            if (jsonObject.optInt("code", 0) == 200) {
                                                Variables.reloadMyVideos = true
                                                Variables.reloadMyVideosInner = true
                                                deleteDraftFile(draftFile)
                                                Functions.showToast(
                                                    SmusixApplication.appLevelContext,
                                                    SmusixApplication.appLevelContext?.getString(R.string.your_video_is_uploaded_successfully)
                                                )
                                            }
                                            continuation.resume(Result.success())
                                            sendBroadByName(Variables.homeBroadCastAction,responses)
                                            sendBroadByName(Variables.profileBroadCastAction,responses)
                                        }
                                        catch (e: Exception) {
                                            Functions.printLog(Constants.tag, "Exception: $e")
                                            continuation.resume(Result.failure())
                                            sendBroadByName(Variables.homeBroadCastAction,responses)
                                            sendBroadByName(Variables.profileBroadCastAction,responses)
                                        }
                                    }

                                })

                            }
                            .addOnFailureListener { e ->
                                Functions.printLog(Constants.tag, "Error")
                                continuation.resume(Result.failure())
                                sendBroadByName(Variables.homeBroadCastAction,"Error")
                                sendBroadByName(Variables.profileBroadCastAction,"Error")
                            }

                    }
                    .addOnFailureListener { exception ->
                        Functions.printLog(Constants.tag, "Error")
                        continuation.resume(Result.failure())
                        sendBroadByName(Variables.homeBroadCastAction,"Error")
                        sendBroadByName(Variables.profileBroadCastAction,"Error")
                        }

            }
            result
        } catch (e: Exception) {
            Functions.printLog(Constants.tag, "Exception: $e")
            Result.failure()

        }
    }


    private fun createForegroundInfo(): ForegroundInfo {

        val channelId = "my_channel_id"
        val channelName = "Background Worker"

        // Create channel for Android O+ (VERY IMPORTANT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager =
                applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(chan)
        }

        val notification = NotificationCompat.Builder(applicationContext, channelId)
            .setSmallIcon(R.drawable.ic_upload)   // MUST NOT be 0 !!!
            .setContentTitle(applicationContext.getString(R.string.video_uploading))
            .setContentText(applicationContext.getString(R.string.please_wait_your_video_is_uploading))
            .setOngoing(true)
            .build()

        return ForegroundInfo(1, notification)
    }


    private fun sendBroadByName(action: String, response: String) {
        val intent = Intent(action)
        intent.setPackage(SmusixApplication.appLevelContext?.packageName)
        intent.putExtra("response",response)
        SmusixApplication.appLevelContext?.sendBroadcast(intent)
    }

    private fun deleteDraftFile(draftFile: String?) {
        draftFile?.let {
            val file = File(it)
            if (file.exists()) {
                file.delete()
            }
        }
    }



}