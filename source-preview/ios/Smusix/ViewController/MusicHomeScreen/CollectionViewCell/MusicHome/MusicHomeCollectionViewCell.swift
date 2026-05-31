import UIKit
import GSPlayer
import DSGradientProgressView
import AVFoundation
import Lottie
import MediaPlayer

protocol MusicHomeCollectionViewCellDelegate: AnyObject {
    func didFinishPlayingVideo(at index: Int)
    func backPlayingVideo(at index: Int)
    func reloadAPI()
}

class MusicHomeCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: MusicHomeCollectionViewCellDelegate?
    var currentIndex: Int = 0 // Track the current index
    var test = false
    
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var imgPlay: UIImageView!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnBackward: UIButton!
    @IBOutlet var btnForward: UIButton!
    @IBOutlet var lblStarting: UILabel!
    @IBOutlet var musicSlider: UISlider!
    @IBOutlet var lblTotalVideo: UILabel!
    @IBOutlet var btnTop100: UIButton!
    @IBOutlet var btnHeart: UIButton!
    @IBOutlet var btnComment: UIButton!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnImage: UIButton!
    @IBOutlet var imgProfile: CustomImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgVerified: UIImageView!
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var videoView: VideoPlayerView!
    @IBOutlet var progressView: DSGradientProgressView!
    @IBOutlet var lblHeartCount: UILabel!
    @IBOutlet var lblShareCount: UILabel!
    @IBOutlet var lblCommentCount: UILabel!
    
    private var url: URL!
    private var totalDuration: Double = 0
    private var playerTimeObserver: Any?
    private var isSliderBeingUsed = false
    private var isBuffering: Bool = false
    
    var starting_time = ""
    var total_time = ""
    var videoCount = 0
    var isLiked = false
    private var isCommandExecuting = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupRemoteTransportControls()
        videoView.contentMode = .scaleAspectFill
        videoView.isAutoReplay = false
        videoView.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                print("error - \(error.localizedDescription)")
                self.progressView.wait()
                self.progressView.isHidden = false
                self.delegate?.reloadAPI()
                NotificationCenter.default.post(name: Notification.Name("errInPlay"), object: nil, userInfo: ["err": error.localizedDescription])
                
            case .loading:
                print("loading")
                self.progressView.wait()
                self.progressView.isHidden = false
                
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                
                if playing == 1.0 { // Video paused because it reached the end
                    self.delegate?.didFinishPlayingVideo(at: self.currentIndex)
                }
                
                if isBackground {
                    if playing == 0.0 && self.test == false {
                        self.delegate?.didFinishPlayingVideo(at: self.currentIndex)
                    }
                }
                
                self.imgPlay.image = UIImage(systemName: "play.fill")
                self.progressView.signal()
                self.progressView.isHidden = true
                self.stopUpdatingProgress()
                
            case .playing:
                self.imgPlay.image = UIImage(systemName: "pause.fill")
                self.progressView.isHidden = true
                self.startUpdatingProgress()
                print("playing")
            }
        }
        
        musicSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        let value = Double(slider.value)
        let timeInSeconds = value * totalDuration
        
        let time = CMTime(seconds: timeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        lblStarting.text = formatTimeString(timeInSeconds)
        
        if isBuffering {
            videoView.stateDidChanged = { [weak self] state in
                guard state == .playing else { return }
                self?.videoView.seek(to: time)
                self?.videoView.stateDidChanged = nil
                self?.isBuffering = false
            }
        } else {
            videoView.seek(to: time)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoView.isHidden = true
        stopUpdatingProgress() // Ensure time observer is removed
    }
    
    func set(url: URL) {
        self.url = url
    }
    
    func play(atIndex index: Int) {
        self.currentIndex = index // Update the current index
        videoView.play(for: url)
        videoView.isHidden = false
        
        // Fetch video duration asynchronously
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let asset = AVURLAsset(url: self.url)
            let duration = CMTimeGetSeconds(asset.duration)
            
            DispatchQueue.main.async {
                self.totalDuration = duration
                self.lblTotalVideo.text = self.formatTimeString(self.totalDuration)
            }
        }
    }
    
    func pause() {
        videoView.pause(reason: .hidden)
        stopUpdatingProgress()
    }
    
    private func formatTimeString(_ time: Double) -> String {
        guard time.isFinite && !time.isNaN else {
            return "00:00"
        }
        
        let totalSeconds = Int(time)
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startUpdatingProgress() {
        guard playerTimeObserver == nil else { return }
        
        // Observe changes in the player's time
        playerTimeObserver = videoView.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: DispatchQueue.main
        ) { [weak self] time in
            guard let self = self, !self.isSliderBeingUsed else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            let progress = currentTime / self.totalDuration
            self.updateProgressBar(with: progress)
            
            if currentTime >= self.totalDuration {
                self.stopUpdatingProgress() // Remove the observer when playback reaches the end
                self.delegate?.didFinishPlayingVideo(at: self.currentIndex)
            }
        }
    }
    
    private func updateProgressBar(with progress: Double) {
        lblStarting.text = formatTimeString(progress * totalDuration)
        musicSlider.value = Float(progress)
    }
    
    func stopUpdatingProgress() {
        if let observer = playerTimeObserver {
            videoView.removeTimeObserver(observer)
            playerTimeObserver = nil
        }
    }
    
    func like() {
        self.btnHeart.setImage(UIImage(named: "Heart"), for: .normal)
        isLiked = true
    }
    
    func unlike() {
        self.btnHeart.setImage(UIImage(named: "heartAniIcon"), for: .normal)
        isLiked = false
    }
    
    func alreadyLiked() {
        self.btnHeart.setImage(UIImage(named: "Heart"), for: .normal)
        isLiked = true
    }
    
    func updateNowPlayingInfo(withTitle title: String, artist: String, artwork: UIImage?, currentIndex: Int) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        // Clear existing artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = nil
        
        if let artworkImage = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
                return artworkImage
            }
        }
        
        // Adding current index to now playing info
        nowPlayingInfo["currentIndex"] = currentIndex
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.removeTarget(nil)

        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.test = true
            self.play(atIndex: self.currentIndex)
            self.test = false
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.test = true
            self.pause()
            self.test = false
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            let currentIndex = self.currentIndex
            guard currentIndex <= (self.videoCount - 1) else { return .commandFailed }
            self.videoView.pause(reason: .hidden)
            self.delegate?.didFinishPlayingVideo(at: currentIndex)
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            let currentIndex = self.currentIndex
            guard currentIndex >= 0 else { return .commandFailed }
            self.videoView.pause(reason: .hidden)
            self.delegate?.backPlayingVideo(at: currentIndex)
            return .success
        }
    }
}
