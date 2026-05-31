package com.smusix.app.simpleclasses.ffmpegCalling

class Statistics(
    var sessionId: Long,
    var videoFrameNumber: Int,
    var videoFps: Float,
    var videoQuality: Float,
    var size: Long,
    var time: Double,
    var bitrate: Double,
    var speed: Double
) {
    override fun toString(): String {
        val stringBuilder = StringBuilder()
        stringBuilder.append("Statistics{")
        stringBuilder.append("sessionId=")
        stringBuilder.append(this.sessionId)
        stringBuilder.append(", videoFrameNumber=")
        stringBuilder.append(this.videoFrameNumber)
        stringBuilder.append(", videoFps=")
        stringBuilder.append(this.videoFps)
        stringBuilder.append(", videoQuality=")
        stringBuilder.append(this.videoQuality)
        stringBuilder.append(", size=")
        stringBuilder.append(this.size)
        stringBuilder.append(", time=")
        stringBuilder.append(this.time)
        stringBuilder.append(", bitrate=")
        stringBuilder.append(this.bitrate)
        stringBuilder.append(", speed=")
        stringBuilder.append(this.speed)
        stringBuilder.append('}')
        return stringBuilder.toString()
    }
}