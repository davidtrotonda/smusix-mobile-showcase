package com.smusix.app.simpleclasses.ffmpegCalling


interface FFmpegCallBack {
    fun process(logMessage: LogMessage){}
    fun statisticsProcess(statistics: Statistics) {}
    fun success(){}
    fun cancel(){}
    fun failed(){}
}