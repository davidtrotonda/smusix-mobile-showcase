package com.smusix.app.simpleclasses.ffmpegCalling

import ai.instavision.ffmpegkit.FFmpegKit
import ai.instavision.ffmpegkit.FFmpegKitConfig
import ai.instavision.ffmpegkit.Log
import ai.instavision.ffmpegkit.LogCallback
import ai.instavision.ffmpegkit.ReturnCode
import android.os.Handler
import android.os.Looper
import java.util.concurrent.CyclicBarrier

/**
 * Created by Ashvin Vavaliya on 22,January,2021
 * Simform Solutions Pvt Ltd.
 */
class CallBackOfQuery {
    fun callQuery(query: Array<String>, fFmpegCallBack: FFmpegCallBack) {
        val gate = CyclicBarrier(2)
        object : Thread() {
            override fun run() {
                gate.await()
                process(query, fFmpegCallBack)
            }
        }.start()
        gate.await()
    }

    fun cancelProcess(executionId: Long) {
        if (!executionId.equals(0)) {
            FFmpegKit.cancel(executionId)
        } else {
            FFmpegKit.cancel()
        }
    }

    fun cancelProcess() {
        FFmpegKit.cancel()
    }

    private fun process(query: Array<String>, ffmpegCallBack: FFmpegCallBack) {
        val processHandler = Handler(Looper.getMainLooper())
        FFmpegKitConfig.enableLogCallback(object : LogCallback {
            override fun apply(logMessage: Log) {
                val logs = LogMessage(logMessage.sessionId, logMessage.level, logMessage.message)
                processHandler.post {
                    ffmpegCallBack.process(logs)
                }
            }
        })
        FFmpegKitConfig.enableStatisticsCallback { statistics ->
            val statisticsLog =
                Statistics(
                    statistics.sessionId,
                    statistics.videoFrameNumber,
                    statistics.videoFps,
                    statistics.videoQuality,
                    statistics.size,
                    statistics.time,
                    statistics.bitrate,
                    statistics.speed
                )
            processHandler.post {
                ffmpegCallBack.statisticsProcess(statisticsLog)
            }
        }

        FFmpegKit.executeWithArgumentsAsync(query) { session ->
            val returnCode = session.returnCode
            processHandler.post {
                when {

                    ReturnCode.isSuccess(returnCode) -> {
                        ffmpegCallBack.success()
                    }
                    ReturnCode.isCancel(returnCode) -> {
                        ffmpegCallBack.cancel()
                    }
                    else -> {
                        ffmpegCallBack.failed()
                    }
                }
            }
        }
    }
}