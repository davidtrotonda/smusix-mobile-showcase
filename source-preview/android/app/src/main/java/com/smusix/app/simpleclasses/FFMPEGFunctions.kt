package com.smusix.app.simpleclasses

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.util.Log
import com.smusix.app.simpleclasses.ffmpegCalling.CallBackOfQuery
import com.smusix.app.simpleclasses.ffmpegCalling.Common
import com.smusix.app.simpleclasses.ffmpegCalling.FFmpegCallBack
import com.smusix.app.simpleclasses.ffmpegCalling.LogMessage
import com.smusix.app.Constants
import com.smusix.app.interfaces.FragmentCallBack
import java.io.File


object FFMPEGFunctions {

    @JvmStatic
    fun getFilePath(activity: Activity):String{
        return Common.getFilePath(activity, Common.VIDEO);
    }


    fun addImageProcess(stickerPath: String,
                        videoFile:File, outputPath:String,
                        callback:FragmentCallBack) {

        val query = addVideoWaterMark(videoFile.absolutePath, stickerPath, outputPath)
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }

            }

            override fun success() {
                Log.d(Constants.tag,"success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",outputPath)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d(Constants.tag,"cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d(Constants.tag,"failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }


    fun trimVideoProcess(videoFile:File, outputPath:String,
                         startTimeString:String,endTimeString:String,
                         callback: FragmentCallBack) {

        val query = cutVideo(videoFile.absolutePath, startTimeString, endTimeString, outputPath)
        Log.d("FFMPEG_",query.toString())
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }
            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",outputPath)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }


    fun compressVideoHighToLowProcess(activity: Activity, videoFile:File,
                                      frameRate:Int,
                                      callback: FragmentCallBack) {
        val outputPath = Common.getFilePath(activity, Common.VIDEO)
        val query = highToLowCompressor(videoFile.absolutePath, outputPath,frameRate)
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }

            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",outputPath)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }




    fun videoSpeedProcess(context: Context,inputPath:String,speedTabPosition:Int,
                          frameRate:Int,
                          callback: FragmentCallBack) {
        val outputPath = Common.getFilePath(context, Common.VIDEO)
        var setpts:Double=1.0
        var atempo:Double=1.0
        Log.d(Constants.tag,"speedTabPosition: $speedTabPosition")
        when(speedTabPosition)
        {
            0->{
                setpts=2.0
                atempo=0.5
            }
            1->{
                setpts=1.5
                atempo=0.75
            }
            2->{
                setpts=1.0
                atempo=1.0
            }
            3->{
                setpts=0.75
                atempo=1.5
            }
            4->{
                setpts=0.5
                atempo=2.0
            }else->{
            setpts=1.0
            atempo=1.0
        }

        }

        val query = videoMotion(inputPath, outputPath,setpts,atempo,frameRate)
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }

            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                try {
                    Functions.copyFile(File(outputPath), File(inputPath))
                    Functions.clearFilesCacheBeforeOperation(File(outputPath))
                } catch (e: Exception) {
                    Functions.printLog(Constants.tag, "" + e)
                }
                bundle.putString("path",inputPath)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }



    fun ConcatenateMultipleVideos(activity: Activity,videoPaths: ArrayList<String>, output:String,
                                      callback: FragmentCallBack) {
        val query = ConcateVideos(videoPaths, output)
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }

            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",output)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }



    private fun getCombineImagesToVideo(inputs:ArrayList<String>, query: String, queryAudio: String, paths: ArrayList<String>, output: String): Array<String> {
        Log.d(Constants.tag,"inputsquery: ${inputs}")
        val width = 620
        val height = 1102
        inputs.apply {
            add("-f")
            add("lavfi")
            add("-t")
            add("0.1")
            add("-i")
            add("anullsrc")
            add("-filter_complex")
            add(query + queryAudio + "concat=n=" + paths.size + ":v=1:a=1 [v][a]")
            add("-s")
            add("${width}x${height}")
            add("-map")
            add("[v]")
            add("-map")
            add("[a]")
            add("-r")
            add("25")
            add("-vcodec")
            add("mpeg4")
            add("-b:v")
            add("15M")
            add("-b:a")
            add("48000")
            add("-ac")
            add("2")
            add("-ar")
            add("22050")
            add(output)
        }
        Log.d(Constants.tag,"inputsfinal: ${inputs}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }


    fun addVideoWaterMark(inputVideo: String, imageInput: String, output: String): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-i")
            add(inputVideo)
            add("-i")
            add(imageInput)
            add("-filter_complex")
            add("[0:v][1:v]overlay=0:0")
            add("-r")
            add("25")
            add("-vcodec")
            add("mpeg4")
            add("-b:v")
            add("15M")
            add("-c:a")
            add("copy")
            add("-max_muxing_queue_size")
            add("9999")
            add(output)
        }
        Log.d(Constants.tag,"inputs AddImage: ${inputs}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }


    fun highToLowCompressor(inputVideo: String, outputVideo: String,frameRate:Int): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-y")
            add("-i")
            add(inputVideo)
            add("-vf")
            add("scale=w='min(620,iw)':h='min(1102,ih)', pad=620:1102:(620-iw)/2:(1102-ih)/2:black")
            add("-r")
            add("${if (frameRate >= 10) frameRate - 5 else frameRate}")
            add("-vcodec")
            add("mpeg4")
            add("-b:v")
            add("15M")
            add("-b:a")
            add("48000")
            add("-ac")
            add("2")
            add("-ar")
            add("22050")
            add(outputVideo)
        }
        Log.d(Constants.tag,"inputs Compression: ${inputs}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }


    fun cutVideo(inputVideoPath: String, startTime: String?, endTime: String?, output: String): Array<String> {
        val inputs: ArrayList<String> = ArrayList()

        inputs.apply {
            add("-ss")
            add(startTime.toString())
            add("-i")
            add(inputVideoPath)
            add("-to")
            add(endTime.toString())
            add("-c:v")
            add("copy")
            add("-c:a")
            add("copy")
            add("-copyts")
            add(output)
        }
        Functions.printLog(Constants.tag,inputs.toString())

        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }


    fun videoMotion(inputVideo: String, output: String, setpts: Double, atempo: Double,frameRate:Int): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-y")
            add("-i")
            add(inputVideo)
            add("-filter_complex")
            add("[0:v]setpts=${setpts}*PTS[v];[0:a]atempo=${atempo}[a]")
            add("-map")
            add("[v]")
            add("-map")
            add("[a]")
            add("-b:v")
            add("15M")
            add("-b:a")
            add("48000")
            add("-r")
            add("$frameRate")
            add("-vcodec")
            add("mpeg4")
            add(output)
        }
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }

    fun rotateVideo(inputVideo: String, output: String): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-i")
            add(inputVideo)
            add("-vf")
            add("transpose=1")
            add("-c:a")
            add("copy")
            add("-b:v")
            add("25M")
            add(output)
        }
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }


    fun ConcateVideos(videos:ArrayList<String>, output: String): Array<String> {
         val inputs: ArrayList<String> = ArrayList()
         val inputStringBuilder = StringBuilder()
         for (i in 0..(videos.size-1)) {

             inputStringBuilder.append("[${i}:v][${i}:a]")

         }

         inputs.apply {
            add("-y")
             for (i in 0..(videos.size-1)) {
                 add("-i")
                 add(videos.get(i))
             }
            add("-filter_complex")

            add(inputStringBuilder.toString()+"concat=n=" + videos.size + ":v=1:a=1[outv][outa]")
             add("-map")
             add("[outv]")
             add("-map")
             add("[outa]")

             add("-b:v")
             add("15M")

             add("-r")
             add("25")

             add("-s")
             add("620x1102")

            add(output)
        }
        Log.d(Constants.tag,"inputsfinal: ${inputs}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }




    fun replaceVideoAudio(inputVideo: String, inputAudio: String, output: String,
                         callback: FragmentCallBack) {
        val query = buildReplaceAudioCmd(inputVideo, inputAudio, output)
        Log.d("FFMPEG_",query.toString())
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }
            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",output)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }


    fun buildReplaceAudioCmd(inputVideo: String, inputAudio: String, output: String): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-i")
            add(inputVideo)          // input video
            add("-i")
            add(inputAudio)          // new AAC audio
            add("-c:v")
            add("copy")              // keep video as-is (no re-encode)
            add("-c:a")
            add("aac")               // ensure audio is AAC
            add("-map")
            add("0:v:0")             // take video from first input
            add("-map")
            add("1:a:0")             // take audio from second input
            add("-shortest")         // stop when shorter stream ends
            add(output)              // output file
        }
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }



    fun convertAudioIntoVideo(inputImage: String, inputAudio: String, output: String,
                          callback: FragmentCallBack) {
        val query = convertAudioToVideo(inputImage, inputAudio, output)
        Log.d("FFMPEG_",query.toString())
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }
            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",output)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }


    fun convertAudioToVideo(inputImage: String, inputAudio: String, output: String): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            // Loop the cover image
            add("-loop")
            add("1")

            add("-framerate")
            add("1")

            add("-i")
            add(inputImage)

            // AAC audio
            add("-i")
            add(inputAudio)
            add("-c:v")
            add("mpeg4")

            add("-q:v")
            add("5")

            // Audio codec
            add("-c:a")
            add("copy")

            add("-shortest")


            add(output)              // e.g. karaokeOutput.mp4
        }
        Log.d(Constants.tag,"inputs convertAudioToVideo: ${inputs}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))

    }


    @JvmStatic
    fun decodeFFMPEGMessage(message: String): String {
        var message = message
        try {
            message = message.replace("  ".toRegex(), " ")
            message = message.replace("  ".toRegex(), " ")
            message = message.replace("  ".toRegex(), " ")
            message = message.replace("fps= ".toRegex(), "")
            message = message.replace("fps=".toRegex(), "")
            message = message.replace("frame= ".toRegex(), "")
            message = message.replace("frame=".toRegex(), "")
            message = message.replace("size= ".toRegex(), "")
            message = message.replace("size=".toRegex(), "")
            message = message.replace("q= ".toRegex(), "")
            message = message.replace("q=".toRegex(), "")
            message = message.replace("time= ".toRegex(), "")
            message = message.replace("time=".toRegex(), "")
            return message
        } catch (e: Exception) {
            Log.d(Constants.tag, "Exception: $e")
        }
        return ""
    }




    fun generateGifFromVideo(activity: Activity, originalVideoFilePath: String, generateGifPath: String, callback: FragmentCallBack) {
        val query = generateGifCommand(originalVideoFilePath, generateGifPath)

        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message = logMessage.text
                Log.d("FFMPEG_", "process: $message")
                if (message.contains("size=") && message.contains("time=")) {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle = Bundle().apply {
                        putString("action", "process")
                        putString("message", message)
                    }
                    callback.onResponce(bundle)
                }
            }

            override fun success() {
                Log.d("FFMPEG_", "GIF generation successful.")
                val bundle = Bundle().apply {
                    putString("action", "success")
                    putString("path", generateGifPath)
                }
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_", "GIF generation canceled.")
                val bundle = Bundle().apply {
                    putString("action", "cancel")
                }
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_", "GIF generation failed.")
                val bundle = Bundle().apply {
                    putString("action", "failed")
                }
                callback.onResponce(bundle)
            }
        })
    }

    fun generateGifCommand(originalVideoFilePath: String, generateGifPath: String): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-ss")
            add("3")  // Start at 3 seconds
            add("-t")
            add("2")  // Duration of 2 seconds
            add("-i")
            add(originalVideoFilePath)
            add("-vf")
            add("fps=10,scale=160:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse")
            add("-loop")
            add("0")
            add(generateGifPath)
        }
        Log.d("FFMPEG_", "GIF Command: ${inputs.joinToString(" ")}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }



    fun compressVideoProcess(activity: Activity, videoFile:File,
                             frameRate:Int,
                             callback: FragmentCallBack) {
        val outputPath = Common.getFilePath(activity, Common.VIDEO)
        val query = compressor(videoFile.absolutePath, outputPath,frameRate)
        CallBackOfQuery().callQuery(query, object : FFmpegCallBack {
            override fun process(logMessage: LogMessage) {
                var message=logMessage.text
                Log.d("FFMPEG_","process: ${message}")
                if (message.contains("size=") && message.contains("time="))
                {
                    message = Functions.decodeFFMPEGMessage(message)
                    val bundle=Bundle()
                    bundle.putString("action","process")
                    bundle.putString("message",message)
                    callback.onResponce(bundle)
                }

            }

            override fun success() {
                Log.d("FFMPEG_","success: ")
                val bundle=Bundle()
                bundle.putString("action","success")
                bundle.putString("path",outputPath)
                callback.onResponce(bundle)
            }

            override fun cancel() {
                Log.d("FFMPEG_","cancel: ")
                val bundle=Bundle()
                bundle.putString("action","cancel")
                callback.onResponce(bundle)
            }

            override fun failed() {
                Log.d("FFMPEG_","failed: ")
                val bundle=Bundle()
                bundle.putString("action","failed")
                callback.onResponce(bundle)
            }
        })
    }

    fun compressor(inputVideo: String, outputVideo: String, frameRate: Int): Array<String> {
        val inputs: ArrayList<String> = ArrayList()
        inputs.apply {
            add("-y")
            add("-i")
            add(inputVideo)
            add("-r")
            add("${if (frameRate >= 10) frameRate - 5 else frameRate}") // Reduce frame rate slightly for smaller size
            add("-vcodec")
            add("mpeg4")
            add("-b:v")
            add("3M")
            add("-maxrate")
            add("3.5M")
            add("-bufsize")
            add("7M")
            add("-acodec")
            add("aac")
            add("-b:a")
            add("192k")
            add("-ar")
            add("48000")
            add(outputVideo)
        }
        Log.d(Constants.tag, "inputs Compression: ${inputs}")
        return inputs.toArray(arrayOfNulls<String>(inputs.size))
    }



}