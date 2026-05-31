import UIKit
import SDWebImage
import AVFoundation
import EFInternetIndicator
import Lottie
import LanguageManager_iOS
import MediaPlayer

class MusicHomeScreenViewController: UIViewController, UIGestureRecognizerDelegate, NotInterstedDelegate, MusicHomeCollectionViewCellDelegate,CommentCountUpdateDelegate,InternetStatusIndicable {
    var internetConnectionIndicator: EFInternetIndicator.InternetViewIndicator?
    

    func notInterstedFunc(status: Bool) {
        self.remove(index: currentVidIP.row)
    }
    
    func CommentCountUpdateDelegate(commentCount: Int) {
        if commentCount == 1 {
            updateCommentCountOfVideo()
        }
    }
    
    func updateCommentCountOfVideo(){
        var uid = UserDefaultsManager.shared.user_id
        ApiHandler.sharedInstance.showVideoDetail(user_id: uid, video_id: self.videoID) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let resMsg = response?.value(forKey: "msg") as! NSDictionary
                    
                    let videoDic = resMsg.value(forKey: "Video") as! NSDictionary
                    let userDic = resMsg.value(forKey: "User") as! NSDictionary
                    let soundDic = resMsg.value(forKey: "Sound") as! NSDictionary
                    
                    print("videoDic: ",videoDic)
                    print("userDic: ",userDic)
                    print("soundDic: ",soundDic)
                    
                    let likeCount = videoDic.value(forKey: "like_count")
                    let commentCount = videoDic.value(forKey: "comment_count")
                    let like = videoDic.value(forKey: "like")
                    let thum1 = videoDic.value(forKey: "thum") as? String
                    //                    let repost_count = videoDic.value(forKey: "repost_count")
                    
                    let cell = self.musicCollectionView.cellForItem(at: self.currentVidIP) as? MusicHomeCollectionViewCell
                    //                cell?.playerView.pause()
                    //                cell?.pause()
                    cell?.lblHeartCount.text = "\(likeCount!)"
                    cell?.lblCommentCount.text = "\(commentCount!)"
                    
                    let liked = "\(like!)"
                    if liked == "1"{
                        //                            cell?.like()
                        cell?.alreadyLiked()
                        
                    }else{
                        cell?.unlike()
                    }
                    print("likedd: ",like!)
                    
                    let vidDetail = videoDetailMVC(vidLikes: "\(likeCount!)", vidComments: "\(commentCount!)", isLike: "\(like!)", thum: "\(thum1)")
                    
                    self.videoDetail.append(vidDetail)
                    
                }
            }
            
        }
    }
    

    func didFinishPlayingVideo(at index: Int) {
        
        if !isWorking{
            print("Finished playing video at index: \(index)")
            
            guard index < videosMainArr.count else {
                let cell = musicCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MusicHomeCollectionViewCell
                cell?.pause()
                return
            }
            
            // Check if index + 1 is within bounds
            guard index + 1 < videosMainArr.count else {
                print("Next index is out of bounds")
                return
            }

            let vidObj = videosMainArr[index + 1]
            let vidString = AppUtility?.detectURL(ipString: vidObj.videoURL)
            let vidURL = URL(string: vidString!)
            print("vidURL",vidURL!)
           
        
            
            UserDefaults.standard.set(false, forKey: "isFirstTime")
            self.imageView.isHidden = true
            
            // Reset UI elements for the current cell
             let cell = musicCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MusicHomeCollectionViewCell
            cell?.lblStarting.text = "00:00"
                cell?.musicSlider.value = 0.0
            
           
            let nextIndex = index + 1
           
            guard nextIndex <= (videosMainArr.count - 1) else {
                return
            }

            let nextIndexPath = IndexPath(item: nextIndex, section: 0)
            index123 = nextIndexPath
            // Perform batch updates to smoothly scroll to the next video
            self.musicCollectionView.performBatchUpdates(nil, completion: { _ in
                // Disable paging to prevent unintended scrolls during the animation
                self.musicCollectionView.isPagingEnabled = false
                // Animate the scroll to the next video
                UIView.animate(withDuration: 0.1, animations: {
                    self.musicCollectionView.scrollToItem(at: nextIndexPath, at: .bottom, animated: false)
                }, completion: { _ in
                    // Re-enable paging after the animation completes
                    self.musicCollectionView.isPagingEnabled = true
                })
            })
            
            if isBackground {
                
                self.WatchVideo(video_id: videoID)
                getVideoDetails(ip: nextIndexPath)
             
                
                let cell1 = musicCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MusicHomeCollectionViewCell
                
                let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
                for i in visiblePaths  {
                    print("i",i)
                    let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
                    
                    if let url = URL(string: vidObj.videoGIF) {
                        print("vidObj.videoGIF",url)
                        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                            if let image = image {
                                cell?.updateNowPlayingInfo(withTitle: "Smusix", artist: vidObj.username, artwork: image, currentIndex: index + 1)
                            } else {
                                print("Error loading image:", error ?? "Unknown error")
                            }
                        }
                    }
                }
              

                cell1?.set(url: vidURL!)
                cell1?.play(atIndex: index + 1)
            
                
                self.musicCollectionView.reloadData()
                
            }
            
            
        }else{
            
            

        }
    }

    @objc func methodOfReceivedNotification(notification: Notification) {
        
        if videosMainArr.count == 0{
            return
        }
    
        let vidObj = videosMainArr[index123.row]
        let cell = musicCollectionView.cellForItem(at: IndexPath(item: index123.row, section: 0)) as? MusicHomeCollectionViewCell
        let vidString = AppUtility?.detectURL(ipString: vidObj.videoURL)
        let vidURL = URL(string: vidString!)
        cell?.set(url: vidURL!)
        cell?.play(atIndex: index123.row)
        
        let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            print("i",i)
            let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
            
            if let url = URL(string: vidObj.videoGIF) {
                print("vidObj.videoGIF",url)
                SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                    if let image = image {
                        cell?.updateNowPlayingInfo(withTitle: "Smusix", artist: vidObj.username, artwork: image, currentIndex: index123.row + 1)
                    } else {
                        print("Error loading image:", error ?? "Unknown error")
                    }
                }
            }
        }
        
        musicCollectionView.reloadData()
        
//        if let url = URL(string: vidObj.videoGIF) {
//            print("vidObj.videoGIF",url)
//            SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, data, error, cacheType, finished, imageURL) in
//                if let image = image {
//                    cell?.updateNowPlayingInfo(withTitle: "Smusix", artist: vidObj.username, artwork: image, currentIndex: index123.row)
//                } else {
//                    print("Error loading image:", error ?? "Unknown error")
//                }
//            }
//        }
        
        
    }

   
    
    
    // Inside backPlayingVideo method of the ViewController:

    func backPlayingVideo(at index: Int) {
        if !isWorking{
            print("Finished playing video at index: \(index)")
            
            UserDefaults.standard.set(false, forKey: "isFirstTime")
            self.imageView.isHidden = true
            
            // Reset UI elements for the current cell
            if let cell = musicCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MusicHomeCollectionViewCell {
                cell.lblStarting.text = "00:00"
                cell.musicSlider.value = 0.0
            }
           
            // Calculate the index of the previous video
            let previousIndex = index - 1
            
            // Check if the previous index is within the bounds of the array
            guard previousIndex >= 0 else {
                return // If not, exit the function
            }
         
            // Create an IndexPath for the previous video
            let previousIndexPath = IndexPath(item: previousIndex, section: 0)
           
            // Perform batch updates to smoothly scroll to the previous video
            self.musicCollectionView.performBatchUpdates(nil, completion: { _ in
                // Disable paging to prevent unintended scrolls during the animation
                self.musicCollectionView.isPagingEnabled = false
                // Animate the scroll to the previous video
                UIView.animate(withDuration: 0.1, animations: {
                    self.musicCollectionView.scrollToItem(at: previousIndexPath, at: .top, animated: false)
                }, completion: { _ in
                    // Re-enable paging after the animation completes
                    self.musicCollectionView.isPagingEnabled = true
                })
            })
            
            
            
        }else{
            
        }
       
        // Reload the collection view to update the UI
       
    }
    


    func reloadAPI() {
        self.getAllVideos(startPoint: "0", video_type: "all", language: UserDefaultsManager.shared.langauge)
    }
    
    var musicOption = ["Following","Music","English"]
    
    var englishCategories = ["All","HIP-HOP/RAP","POP","TRAP/DRILL","R&B/SOUL","INDIE/ROCK"]
    
    
    var spanishCategories = ["Todos","Pop","Hip-Hop/Rap","Urbano","Latino","Trap/Drill","Indie/Rock"]
    
    var germanCategories = ["Alle","Pop","Hip-Hop/Rap","Trap/Drill","R&B/Soul","Indie/Rock"]
    
    var italianCategories = ["Tutti","Pop","Hip-Hop/Rap","Trap/Drill","R&B/Soul","Indie/Rock"]
    
    var frenchCategories = ["Tous","Pop","Hip-Hop/Rap","Trap/Drill","R&B/Soul","Variété","Indie/Rock"]
    
    var portugueseCategories = ["Todos","Pop","Hip-Hop/Rap","Trap/Drill","Funk","R&B/Soul","Indie/Rock"]
    
    
    @IBOutlet weak var btn0: UIButton!
    
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    
    
    @IBOutlet weak var category7: UIView!
    
    
    
    
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "theme")
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    
    
    var videosMainArr = [videoMainMVC]()
    var videosRelatedArr = [videoMainMVC]()
    var language = ""
    var currentVidIP : IndexPath!
    var videoEmpty = true
    var videoID = ""
    var videoURL = ""
    var startPoint = 0
    var isFollowing = false
    
    @IBOutlet var musicOptionCollectionView: UICollectionView!
    
    @IBOutlet var categoryView8: UIView!
    
    @IBOutlet var musicCollectionView: UICollectionView!
     
    @IBOutlet var languageView: UIView!
    
    
    @IBOutlet var categoryView: UIView!
    
    @IBOutlet var viewCategory1: NSLayoutConstraint!
    
    //Category
    @IBOutlet var lblNoFollowing: UILabel!
    
    @IBOutlet var lblCategory1: UILabel!
    @IBOutlet var lblCategory2: UILabel!
    @IBOutlet var lblCategory3: UILabel!
    @IBOutlet var lblCategory4: UILabel!
    @IBOutlet var lblCategory5: UILabel!
    
    @IBOutlet var lblCategory6: UILabel!
    @IBOutlet var lblCategory7: UILabel!
    @IBOutlet var lblCategory8: UILabel!
    
    @IBOutlet weak var categoryView0: UIView!
    @IBOutlet var lblCategory9: UILabel!
    @IBOutlet var categoryView9: UIView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    private var animationView: AnimationView?
    
    var videoDetail = [videoDetailMVC]()
    var gene = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.tabBar.backgroundColor = .black
        setNeedsStatusBarAppearanceUpdate()
        
        if UserDefaultsManager.shared.langauge == "Spanish" {
            musicOption[2] = UserDefaultsManager.shared.langauge
            musicOption[1] = "Todos"
        }else if UserDefaultsManager.shared.langauge == "English"{
            musicOption[2] = UserDefaultsManager.shared.langauge
            musicOption[1] = UserDefaultsManager.shared.category
            
        }else if UserDefaultsManager.shared.langauge == "German"{
            musicOption[2] = UserDefaultsManager.shared.langauge
            musicOption[1] = "Alle"
            
        }else if UserDefaultsManager.shared.langauge == "Italian"{
            musicOption[2] = UserDefaultsManager.shared.langauge
            musicOption[1] = "Tutti"
            
        }else if UserDefaultsManager.shared.langauge == "French"{
            musicOption[2] = UserDefaultsManager.shared.langauge
            musicOption[1] = "Tous"
            
        }else if UserDefaultsManager.shared.langauge == "Portuguese"{
            musicOption[2] = UserDefaultsManager.shared.langauge
            musicOption[1] = "Todos"
            
        }
        
        
        check()
        
        self.getUserDetails()
        musicOptionCollectionView.delegate = self
        musicOptionCollectionView.dataSource = self
        
        let screenWidth = UIScreen.main.bounds.width - 40

        self.viewCategory1.constant = screenWidth/2
        
        
        musicCollectionView.delegate = self
        musicCollectionView.dataSource = self
        
        
        musicOptionCollectionView.register(UINib(nibName: "MusicOptionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MusicOptionsCollectionViewCell")
        musicCollectionView.register(UINib(nibName: "MusicHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MusicHomeCollectionViewCell")
        
        if UserDefaultsManager.shared.category == "Todos" || UserDefaultsManager.shared.category == "Alle" || UserDefaultsManager.shared.category == "Tutti" || UserDefaultsManager.shared.category == "Tous"{
            self.getAllVideos(startPoint: "0", video_type: "all", language: UserDefaultsManager.shared.langauge.lowercased())
        }else{
            if UserDefaultsManager.shared.category == "Hip-Hop/Rap" || UserDefaultsManager.shared.category == "HIP-HOP/RAP" {
                gene = "hip_hop_rap"
            }else if UserDefaultsManager.shared.category == "TRAP/DRILL" || UserDefaultsManager.shared.category == "Trap/Drill" {
                gene = "trap_drill"
            }else if UserDefaultsManager.shared.category == "R&B/SOUL" || UserDefaultsManager.shared.category == "R&B/Soul" {
                gene = "r_b_soul"
            }else if UserDefaultsManager.shared.category == "INDIE/ROCK" || UserDefaultsManager.shared.category == "Indie/Rock"{
                gene = "indie_rock"
            }else{
                gene = UserDefaultsManager.shared.category.lowercased()
            }
            self.getAllVideos(startPoint: "0", video_type: gene, language: UserDefaultsManager.shared.langauge.lowercased())
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("reload"), object: nil)

        
      
        self.tapGesturesFunc()
        
        self.setupAudio()
        self.startMonitoringInternet()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSoundPlay(notification:)), name: .stopSoundPlayNotify, object: nil)
        
        if #available(iOS 10.0, *) {
            musicCollectionView.refreshControl = refresher
        } else {
            musicCollectionView.addSubview(refresher)
        }
        
        print("UserDefaults.standard.bool(forKe",UserDefaults.standard.bool(forKey: "isFirstTime"))
        if UserDefaults.standard.bool(forKey: "isFirstTime") == true {
            self.imageView.isHidden = false
            
            // Ensure the imageView is visible
            self.imageView.isHidden = false

            // Initialize the animation view with the specified animation
            self.animationView = .init(name: "thumb")

            // Set animation content mode
            self.animationView!.contentMode = .scaleAspectFit

            // Set animation loop mode
            self.animationView!.loopMode = .loop

            // Adjust animation speed
            self.animationView!.animationSpeed = 0.5

            // Add the animation view as a subview of the imageView
            self.imageView.addSubview(self.animationView!)

            // Adjust the animation view's frame to fit within the imageView
            self.animationView!.frame = self.imageView.bounds

            // Play the animation
            self.animationView!.play()


        }else{
            self.imageView.isHidden = true
        }
        
    }
    
   
    
    func getUserDetails(){
        
        
        ApiHandler.sharedInstance.showOwnDetail(user_id: UserDefaultsManager.shared.user_id) { (isSuccess, response) in
           
            if isSuccess{

                print("response: ",response?.allValues)
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let userObjMsg = response?.value(forKey: "msg") as? NSDictionary
                    let userObj = userObjMsg?.value(forKey: "User") as! NSDictionary
                  
                    
                    let wallet = (userObj.value(forKey: "wallet") as? String)
                    if Int(wallet!)! < 0{
            
                        UserDefaultsManager.shared.wallet = "0"
                    }else{
                    
                        UserDefaultsManager.shared.wallet = wallet ?? "0"
                    }
                
                    
                   
                    
                }else{
                    
                    //                    self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                    print("showOwnDetail API:",response?.value(forKey: "msg") as Any)
                }
                
            }else{
                
                //                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
                print("showOwnDetail API:",response?.value(forKey: "msg") as Any)
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
           
            if cell!.videoView.state == .playing {
                cell!.videoView.pause(reason: .userInteraction)
                cell!.stopUpdatingProgress()
                let sessionAV = AVAudioSession.sharedInstance()
                try? sessionAV.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
                
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
                
                UIApplication.shared.endReceivingRemoteControlEvents()
                
                
            } else {
               
            }
            
        }
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.tabBar.backgroundColor = .black
        setNeedsStatusBarAppearanceUpdate()
      
        self.navigationController?.isNavigationBarHidden =  true

        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
       
        
     
        
    }
    
    
    
    @objc func requestData() {
        
        
        print("requesting data")
        self.startPoint = 0
       
        self.isFollowing = false
        
        if UserDefaultsManager.shared.category == "Todos" || UserDefaultsManager.shared.category == "Alle" || UserDefaultsManager.shared.category == "Tutti" || UserDefaultsManager.shared.category == "Tous"{
            self.getAllVideos(startPoint: "\(startPoint)", video_type: "all", language: UserDefaultsManager.shared.langauge.lowercased())
        }else{
            if UserDefaultsManager.shared.category == "Hip-Hop/Rap" || UserDefaultsManager.shared.category == "HIP-HOP/RAP" {
                gene = "hip_hop_rap"
            }else if UserDefaultsManager.shared.category == "TRAP/DRILL" || UserDefaultsManager.shared.category == "Trap/Drill" {
                gene = "trap_drill"
            }else if UserDefaultsManager.shared.category == "R&B/SOUL" || UserDefaultsManager.shared.category == "R&B/Soul" {
                gene = "r_b_soul"
            }else if UserDefaultsManager.shared.category == "INDIE/ROCK" || UserDefaultsManager.shared.category == "Indie/Rock"{
                gene = "indie_rock"
            }else{
                gene = UserDefaultsManager.shared.category.lowercased()
            }
            self.getAllVideos(startPoint: "\(startPoint)", video_type: gene, language: UserDefaultsManager.shared.langauge.lowercased())
        }
        
        
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
        
    }
    
  
    @objc func updateSoundPlay(notification: Notification) {
       print("updateSoundPlay")
      
        
        let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
           
            if cell!.videoView.state == .playing {
                cell!.videoView.pause(reason: .userInteraction)
                cell!.stopUpdatingProgress()
                let sessionAV = AVAudioSession.sharedInstance()
                try? sessionAV.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
                
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
                
                UIApplication.shared.endReceivingRemoteControlEvents()
                
            } else {
               
            }
            
        }
    }
    
    
    func getAllVideos(startPoint:String,video_type:String,language:String){
        lblNoFollowing.isHidden = true
        var userID = UserDefaultsManager.shared.user_id
        
        if userID == "" || userID == nil{
            userID = "0"
        }
        let startingPoint = startPoint
        let deviceID = UserDefaultsManager.shared.deviceID
       
        
        ApiHandler.sharedInstance.showRelatedVideos(device_id: deviceID, user_id: userID, starting_point: startingPoint, video_type: video_type, language: language) { (isSuccess, response) in
            print("res : ",response!)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    
                    if startPoint == "0"{
                        self.videosMainArr.removeAll()
                    }
                    self.videosRelatedArr.removeAll()
                    
                    let resMsg = response?.value(forKey: "msg") as! [[String:Any]]
                    
                    for dic in resMsg{
                        let videoDic = dic["Video"] as! NSDictionary
                        let userDic = dic["User"] as! NSDictionary
                        let soundDic = dic["Sound"] as! NSDictionary
                        
                        print("videoDic: ",videoDic)
                        print("userDic: ",userDic)
                        print("soundDic: ",soundDic)
                        
                        let videoURL = videoDic.value(forKey: "video") as? String
                        let desc = videoDic.value(forKey: "description") as? String
                        let allowComments = videoDic.value(forKey: "allow_comments")
                        let videoUserID = videoDic.value(forKey: "user_id")
                        let videoID = videoDic.value(forKey: "id") as! String
                        let allowDuet = videoDic.value(forKey: "allow_duet")
                        let duetVidID = videoDic.value(forKey: "duet_video_id")
                        
                        //                        not strings
                        let commentCount = videoDic.value(forKey: "comment_count")
                        let likeCount = videoDic.value(forKey: "like_count")
                        let views = videoDic.value(forKey: "view")
                        let repost_count = videoDic.value(forKey: "repost_count")
                        let sound_id = videoDic.value(forKey: "sound_id")
                        //                        let thum = videoDic.value(forKey: "thum")
                        
                        let userImgPath = userDic.value(forKey: "profile_pic") as? String
                        let userName = userDic.value(forKey: "username") as? String
                        let followBtn = userDic.value(forKey: "button") as? String
                        let uid = userDic.value(forKey: "id") as? String
                        let verified = userDic.value(forKey: "verified")
                        let followers_count = userDic.value(forKey: "followers_count")
                        
                        let first_name = userDic.value(forKey: "first_name")
                        let last_name = userDic.value(forKey: "last_name")
                        
                        let soundName = soundDic.value(forKey: "name")
                        let thum = soundDic.value(forKey: "thum")
                        let thum1 = videoDic.value(forKey: "thum") as? String
                        let share = videoDic.value(forKey: "share") as? String
                        let promote = videoDic.value(forKey: "promote")
                        let gif = videoDic.value(forKey: "gif") as! String
                        
                        
                        
                        
                        let videoObj = videoMainMVC(videoID: videoID, videoUserID: "\(videoUserID!)", fb_id: "", description: desc ?? "", videoURL: videoURL ?? "", videoTHUM: "\(thum ?? "")", videoGIF: "\(gif)", view: "", section: "", sound_id: "\(sound_id ?? "")", privacy_type: "", allow_comments: "\(allowComments!)", allow_duet: "\(allowDuet!)", block: "", duet_video_id: "", old_video_id: "", created: "", like: "", favourite: "", comment_count: "\(commentCount!)", like_count: "\(likeCount!)", followBtn: followBtn ?? "", duetVideoID: "\(duetVidID!)", views: "\(views ?? "")", repostCount: "\(repost_count ?? "")",promote: "\(promote ?? "")", videoThum: "\(thum1)", userID: uid ?? "", first_name: "\(first_name ?? "")", last_name: "\(last_name ?? "")", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImgPath  ?? "", role: "", username: userName  ?? "", social: "", device_token: "\(share ?? "")", videoCount: "", verified: "\(verified!)", followersCount: "\(followers_count ?? "")", soundName: "\(soundName!)")
                        self.videosRelatedArr.append(videoObj)
                    }
                    
                   
                    self.videosMainArr.append(contentsOf: self.videosRelatedArr)
                    
                    self.videoEmpty = false
                    self.musicCollectionView.reloadData()
                    print("response@200: ",response!)
                    
                   
                }
                else{
                   
                    if startPoint == "0"{
                        self.videosMainArr.removeAll()
                        
                    }
                    self.musicCollectionView.reloadData()
                    self.videoEmpty = true
                }
                
            }else{
                print("response failed: ",response!)
               
            }
            
        }
    }
    
    
    @IBAction func languageChange(_ sender: UIButton) {
        if sender.tag == 0{
            UserDefaultsManager.shared.langauge = "English"
            self.musicOption[2] = UserDefaultsManager.shared.langauge
            self.musicOption[1] = englishCategories[0]
            
            UserDefaultsManager.shared.category = englishCategories[0]
            
           

        }else if sender.tag == 1{
            
            UserDefaultsManager.shared.langauge = "Spanish"
            self.musicOption[2] = UserDefaultsManager.shared.langauge
            self.musicOption[1] = spanishCategories[0]
            
            UserDefaultsManager.shared.category = englishCategories[0]
            
            
        }else if sender.tag == 2{
            
            UserDefaultsManager.shared.langauge = "German"
            self.musicOption[2] = UserDefaultsManager.shared.langauge
            self.musicOption[1] = germanCategories[0]
            
            UserDefaultsManager.shared.category = englishCategories[0]
            
        }else if sender.tag == 3{
            
            UserDefaultsManager.shared.langauge = "Italian"
            self.musicOption[2] = UserDefaultsManager.shared.langauge
            self.musicOption[1] = italianCategories[0]
            
            UserDefaultsManager.shared.category = englishCategories[0]
            
        }else if sender.tag == 4{
            
            UserDefaultsManager.shared.langauge = "French"
            self.musicOption[2] = UserDefaultsManager.shared.langauge
            self.musicOption[1] = frenchCategories[0]
            
            UserDefaultsManager.shared.category = englishCategories[0]
            
        }else if sender.tag == 5{
            
            UserDefaultsManager.shared.langauge = "Portuguese"
            self.musicOption[2] = UserDefaultsManager.shared.langauge
            self.musicOption[1] = portugueseCategories[0]
            
            UserDefaultsManager.shared.category = englishCategories[0]
            
        }

        self.musicOptionCollectionView.reloadData()
        
        self.getAllVideos(startPoint: "0", video_type: UserDefaultsManager.shared.category.lowercased(), language: UserDefaultsManager.shared.langauge.lowercased())
        
        self.languageView.isHidden = true
    }
    
    
    @IBAction func categoryChange(_ sender: UIButton) {
        
        if UserDefaultsManager.shared.langauge == "English"{


            UserDefaultsManager.shared.category = englishCategories[sender.tag]
            self.musicOption[1] = UserDefaultsManager.shared.category
        }else if UserDefaultsManager.shared.langauge == "Spanish"{
            
            UserDefaultsManager.shared.category = spanishCategories[sender.tag]
        
            self.musicOption[1] = UserDefaultsManager.shared.category
            
            
        }else if UserDefaultsManager.shared.langauge == "German"{
           
            UserDefaultsManager.shared.category = germanCategories[sender.tag]
            
            self.musicOption[1] = UserDefaultsManager.shared.category
            
        }else if UserDefaultsManager.shared.langauge == "Italian"{
            UserDefaultsManager.shared.category = italianCategories[sender.tag]
        
            self.musicOption[1] = UserDefaultsManager.shared.category
        }else if UserDefaultsManager.shared.langauge == "French"{
            UserDefaultsManager.shared.category = frenchCategories[sender.tag]
        
            self.musicOption[1] = UserDefaultsManager.shared.category
        }else{
            UserDefaultsManager.shared.category = portugueseCategories[sender.tag]
        
            self.musicOption[1] = UserDefaultsManager.shared.category
        }
        
        
        self.musicOptionCollectionView.reloadData()
        
        if UserDefaultsManager.shared.category == "Todos" || UserDefaultsManager.shared.category == "Alle" || UserDefaultsManager.shared.category == "Tutti" || UserDefaultsManager.shared.category == "Tous"{
            self.getAllVideos(startPoint: "0", video_type: "all", language: UserDefaultsManager.shared.langauge.lowercased())
        }else{
            if UserDefaultsManager.shared.category == "Hip-Hop/Rap" || UserDefaultsManager.shared.category == "HIP-HOP/RAP" {
                gene = "hip_hop_rap"
            }else if UserDefaultsManager.shared.category == "TRAP/DRILL" || UserDefaultsManager.shared.category == "Trap/Drill" {
                gene = "trap_drill"
            }else if UserDefaultsManager.shared.category == "R&B/SOUL" || UserDefaultsManager.shared.category == "R&B/Soul" {
                gene = "r_b_soul"
            }else if UserDefaultsManager.shared.category == "INDIE/ROCK" || UserDefaultsManager.shared.category == "Indie/Rock"{
                gene = "indie_rock"
            }else{
                gene = UserDefaultsManager.shared.category.lowercased()
            }
            self.getAllVideos(startPoint: "0", video_type: gene, language: UserDefaultsManager.shared.langauge.lowercased())
        }
        
        
        self.categoryView.isHidden = true
       
        
    }
    
    
    
    
    @objc func imageButtonPressed(sender: UIButton){
        print(sender.tag)
        
        let obj = videosMainArr[sender.tag]
        print("obj user id : ",obj.userID)
        
        let otherUserID = obj.userID
        let userID = UserDefaultsManager.shared.user_id
        
        if userID == nil || userID == ""{
            
            loginScreenAppear()
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController")as! OtherProfileViewController
            vc.hidesBottomBarWhenPushed = true
            vc.otherUserID = otherUserID
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func `loginScreenAppear`(){
        let myViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: myViewController)
        nav.isNavigationBarHidden =  true
        nav.modalPresentationStyle = .overFullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    func tapGesturesFunc(){
        
        
        
         let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
         singleTapGR.delegate = self
         singleTapGR.numberOfTapsRequired = 1
         musicCollectionView.addGestureRecognizer(singleTapGR)

     
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTapGR.delegate = self
        doubleTapGR.numberOfTapsRequired = 2
        musicCollectionView.addGestureRecognizer(doubleTapGR)
        singleTapGR.require(toFail: doubleTapGR)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delaysTouchesBegan = true
        longPressRecognizer.delegate = self
        musicCollectionView.addGestureRecognizer(longPressRecognizer)
        
        
    }
    
    func WatchVideo(video_id:String){
        
        var userID = UserDefaultsManager.shared.user_id
        
        if userID == "" || userID == nil{
            userID = "0"
        }
        let deviceID = UserDefaultsManager.shared.deviceID
    
        print("deviceid: ",deviceID)
        
        ApiHandler.sharedInstance.watchVideo(device_id: deviceID,video_id:video_id) { (isSuccess, response) in
            
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    print(" WatchVideo response@200: ",response!)
                }
                else{
                    print("WatchVideo response@201: ",response!)
                }
                
            }else{
                print("response failed: ",response!)
                //                self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
            }
            
        }
    }
    
    func getFollowingVideos(startPoint:String){
        
       
        let startingPoint = startPoint
        
        let userID = UserDefaultsManager.shared.user_id
        let deviceID =  UserDefaultsManager.shared.deviceID
        
        
        ApiHandler.sharedInstance.showFollowingVideos(user_id: userID, device_id: deviceID, starting_point: startingPoint) { (isSuccess, response) in
            print("res;: ",response!)
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    
                    if startPoint == "0"{
                        self.videosMainArr.removeAll()
                    }
                    
                    
                    
                    let resMsg = response?.value(forKey: "msg") as! [[String:Any]]
                    
                    for dic in resMsg{
                        let videoDic = dic["Video"] as! NSDictionary
                        let userDic = dic["User"] as! NSDictionary
                        let soundDic = dic["Sound"] as! NSDictionary
                        
                       
                        let promotionDic = videoDic["Promotion"] as? NSDictionary
                        print("promotionDic: ",promotionDic)
                        let actionButton = promotionDic?.value(forKey: "action_button") as? String
                        let audienceId = promotionDic?.value(forKey: "audience_id")
                        let clicks = promotionDic?.value(forKey: "clicks")
                        let coin = promotionDic?.value(forKey: "coin")
                        let destination = promotionDic?.value(forKey: "destination")
                        let destinatioTap = promotionDic?.value(forKey: "destination_tap")
                        let endDatetime = promotionDic?.value(forKey: "end_datetime")
                        let followers = promotionDic?.value(forKey: "followers")
                        let reach = promotionDic?.value(forKey: "reach")
                        let startDatetime = promotionDic?.value(forKey: "start_datetime")
                        let totalReach = promotionDic?.value(forKey: "total_reach")
                        let userId = promotionDic?.value(forKey: "user_id")
                        let videoId = promotionDic?.value(forKey: "video_id")
                        let websiteUrl = promotionDic?.value(forKey: "website_url")
                        
                        
                        
                        print("videoDic: ",videoDic)
                        print("userDic: ",userDic)
                        print("soundDic: ",soundDic)
                        
                        let videoURL = videoDic.value(forKey: "video") as? String
                        let desc = videoDic.value(forKey: "description") as? String
                        let allowComments = videoDic.value(forKey: "allow_comments")
                        let videoUserID = videoDic.value(forKey: "user_id")
                        let videoID = videoDic.value(forKey: "id") as! String
                        let allowDuet = videoDic.value(forKey: "allow_duet")
                        let duetVidID = videoDic.value(forKey: "duet_video_id")
                        
                        //                        not strings
                        let commentCount = videoDic.value(forKey: "comment_count")
                        let likeCount = videoDic.value(forKey: "like_count")
                        let views = videoDic.value(forKey: "view")
                        let repost_count = videoDic.value(forKey: "repost_count")
                        let sound_id = videoDic.value(forKey: "sound_id")
                        
                        let userImgPath = userDic.value(forKey: "profile_pic") as? String
                        let userName = userDic.value(forKey: "username") as? String
                        let followBtn = userDic.value(forKey: "button") as? String
                        let uid = userDic.value(forKey: "id") as? String
                        let verified = userDic.value(forKey: "verified")
                        let followers_count = userDic.value(forKey: "followers_count")
                        let thum1 = videoDic.value(forKey: "thum") as? String
                        let soundName = soundDic.value(forKey: "name")
                        let thum = soundDic.value(forKey: "thum")
                        let promote = videoDic.value(forKey: "promote")
                        
                        
                        let first_name = userDic.value(forKey: "first_name")
                        let last_name = userDic.value(forKey: "last_name")
                        let share = videoDic.value(forKey: "share") as? String
                        
                        let gif = videoDic.value(forKey: "gif") as! String
                        
                        let videoObj = videoMainMVC(videoID: videoID, videoUserID: "\(videoUserID!)", fb_id: "", description: desc ?? "", videoURL: videoURL ?? "", videoTHUM: "\(thum ?? "")", videoGIF: "\(gif)", view: "", section: "", sound_id: "\(sound_id ?? "")", privacy_type: "", allow_comments: "\(allowComments!)", allow_duet: "\(allowDuet!)", block: "", duet_video_id: "", old_video_id: "", created: "", like: "", favourite: "", comment_count: "\(commentCount!)", like_count: "\(likeCount!)", followBtn: followBtn ?? "", duetVideoID: "\(duetVidID!)", views: "\(views ?? "")", repostCount: "\(repost_count ?? "")",promote: "\(promote ?? "")", videoThum: "\(thum1)", userID: uid ?? "", first_name: "\(first_name ?? "")", last_name: "\(last_name ?? "")", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImgPath  ?? "", role: "", username: userName  ?? "", social: "", device_token: "\(share ?? "")", videoCount: "", verified: "\(verified!)", followersCount: "\(followers_count ?? "")", soundName: "\(soundName!)")
                        self.videosMainArr.append(videoObj)
                    }
                  
                    if self.videosMainArr.count == 0{
                        self.lblNoFollowing.isHidden = false
                    }else{
                        self.lblNoFollowing.isHidden = true
                    }
                    
                   
                    self.musicCollectionView.reloadData()
                    print("response@200: ",response!)
                }else{
                    
                    
                    
                    self.lblNoFollowing.isHidden = false
                    self.lblNoFollowing.text = "you are not following anyone yet".localiz()
                    
                   
                    self.videosMainArr.removeAll()
                    
                   
                    self.musicCollectionView.reloadData()
                   
                }
                
                
            }else{
                print("response failed: ",response!)
                
            
            }
            
            //            self.loaderView.stopAnimating()
        }
        
    }
    
    
    @objc func handleSingleTap(_ gesture: UITapGestureRecognizer){
        print("singletapped")
        
        self.languageView.isHidden = true
        
        self.categoryView.isHidden = true
        
        let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
         
            
            if cell!.videoView.state == .playing {
                cell!.videoView.pause(reason: .userInteraction)
               
                //                cell!.btnPlayImg.isHidden = false
            } else {
                //                cell!.btnPlayImg.isHidden = true
                cell!.videoView.resume()
               
            }
            
        }
    }
    var ccuser_id = ""
    func getVideoDetails(ip:IndexPath){
        videoDetail.removeAll()
        
        var uid = UserDefaultsManager.shared.user_id
        
        if uid == nil || uid == ""{
            uid = ""
        }
        
        //        if userVideoArr.isEmpty == false || discoverVideoArr.isEmpty == false{
        //            uid = UserDefaultsManager.shared.otherUserID
        //        }````1
        //
        
        
        ApiHandler.sharedInstance.showVideoDetail(user_id: uid, video_id: self.videoID) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    let resMsg = response?.value(forKey: "msg") as! NSDictionary
                    
                    let videoDic = resMsg.value(forKey: "Video") as! NSDictionary
                    let userDic = resMsg.value(forKey: "User") as! NSDictionary
                    let soundDic = resMsg.value(forKey: "Sound") as! NSDictionary
                    
                    print("videoDic: ",videoDic)
                    print("userDic: ",userDic)
                    print("soundDic: ",soundDic)
                    
                    let likeCount = videoDic.value(forKey: "like_count")
                    let commentCount = videoDic.value(forKey: "comment_count")
                    let like = videoDic.value(forKey: "like")
                    let favourite = videoDic.value(forKey: "favourite")
                    let thum1 = videoDic.value(forKey: "thum") as? String
                  
                   
                    self.ccuser_id = videoDic.value(forKey: "user_id") as! String
                    //  let repost_count = videoDic.value(forKey: "repost_count")
                    
                    let cell = self.musicCollectionView.cellForItem(at: ip) as? MusicHomeCollectionViewCell
                    //                cell?.playerView.pause()
                    //                cell?.pause()
                    
                    
                    cell?.lblHeartCount.text = "\(likeCount!)"
                    cell?.lblCommentCount.text = "\(commentCount!)"
                    
                    print("favourite",favourite)
                    
                    print("userDic",userDic)

                    
                    let followBtn = userDic.value(forKey: "button") as? String ?? ""
                    
                    if uid != ""{
                        print("followBtn",followBtn)
                        if followBtn == "follow" {
                            //            cell.btnFollow.setTitle("UnFollow", for: .normal)
                            //                            cell?.btnAdd.isHidden = false
                            //                            if self.showAdsVideo == true {
                            //                                cell?.btnAdd.isHidden = true
                            //                            }else {
                            //                                cell?.btnAdd.isHidden = false
                            //                            }
                            cell?.btnFollow.setTitle("Follow".localiz(), for: .normal)
                        }else{
                            cell?.btnFollow.setTitle("Following".localiz(), for: .normal)
                            //            cell.btnFollow.setTitle("Follow", for: .normal)
                        }
                        
                    }
                    
            
                    let liked = "\(like!)"
                    if liked == "1"{
                        //                            cell?.like()
                        cell?.alreadyLiked()
                        
                    }else{
                        cell?.unlike()
                    }
                    print("likedd: ",like!)
                    
                    let vidDetail = videoDetailMVC(vidLikes: "\(likeCount!)", vidComments: "\(commentCount!)", isLike: "\(like!)", thum: "\(thum1)")
                    
                    self.videoDetail.append(vidDetail)
                    
                }
            }
            
        }
        
    }
    
    @objc func handleDoubleTap(gesture: UITapGestureRecognizer){
        print("doubletapped")
        let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
            let userID = UserDefaultsManager.shared.user_id
            if userID != ""{
                
                let location = gesture.location(in: cell?.videoView)
                let heartView = UIImageView(image: UIImage(systemName: "heart.fill"))
                heartView.tintColor = .red
                let width : CGFloat = 110
                heartView.contentMode = .scaleAspectFit
                heartView.frame = CGRect(x: location.x - width / 2, y: location.y - width / 2, width: width, height: width)
                heartView.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -CGFloat.pi * 0.2...CGFloat.pi * 0.2))
                cell?.videoView.addSubview(heartView)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: {
                    heartView.transform = heartView.transform.scaledBy(x: 0.85, y: 0.85)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: {
                        heartView.transform = heartView.transform.scaledBy(x: 2.3, y: 2.3)
                        heartView.alpha = 0
                    }, completion: { _ in
                        heartView.removeFromSuperview()
                    })
                })
                
                if cell?.isLiked == false{
                    
                    cell?.like()
                    self.likeVideo(uid:userID,ip: currentVidIP)
                }else{
                    
                   
                }
            }else{
                loginScreenAppear()
            }
        }
    }
    
    
    @objc func btnLikeTapped(sender : UIButton) {
        // Do what you want
     
        let cell = self.musicCollectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? MusicHomeCollectionViewCell
        
        let userID = UserDefaultsManager.shared.user_id
        if userID != ""{
            if cell?.isLiked == false{
                cell?.like()
                self.likeVideo(uid:userID,ip: currentVidIP)
                // self.getVideoDetails(ip: currentVidIP)
            }else{
                cell?.unlike()
                self.likeVideo(uid:userID,ip: currentVidIP)
                //  self.getVideoDetails(ip: currentVidIP)
            }
        }else{
            loginScreenAppear()
        }
    }
    
    
    func likeVideo(uid:String,ip:IndexPath){
        
        let vidID = videoID
        ApiHandler.sharedInstance.likeVideo(user_id: uid, video_id: vidID) { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    print("likeVideo response msg: ",response?.value(forKey: "msg"))
                    
                    let like = response?.value(forKey: "like") as! NSNumber
                    
                    let like_count = response?.value(forKey: "like_count") as! NSNumber
                    
                    let cell = self.musicCollectionView.cellForItem(at: ip) as? MusicHomeCollectionViewCell
                    //                cell?.playerView.pause()
                    //                cell?.pause()
                    cell?.lblHeartCount.text = "\(like_count)"
                    
                    if like == 1 {
                        cell?.alreadyLiked()
                    }else {
                        cell?.unlike()
                    }
                    
                    //                    if let msg = response?.value(forKey: "msg") as? String {
                    //                        self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
                    //
                    //                    }else {
                    //
                    //                    }
                    //                    let resMsg = response?.value(forKey: "msg") as! NSDictionary
                    //
                    //                    let videoDic = resMsg.value(forKey: "Video") as! NSDictionary
                    //                    let userDic = resMsg.value(forKey: "User") as! NSDictionary
                    ////                    let soundDic = resMsg.value(forKey: "Sound") as! NSDictionary
                    //
                    //                    print("videoDic: ",videoDic)
                    //                    print("userDic: ",userDic)
                    ////                    print("soundDic: ",soundDic)
                    //
                    //                    let likeCount = videoDic.value(forKey: "like_count")
                    ////                    let commentCount = videoDic.value(forKey: "comment_count")
                    ////                    let like = videoDic.value(forKey: "like")
                    //                    let repost_count = videoDic.value(forKey: "repost_count")
                    //
                    //                    let cell = self.homeVideoCollectionView.cellForItem(at: ip) as? HomeScreenCollectionViewCell
                    //                    //                cell?.playerView.pause()
                    //                    //                cell?.pause()
                    //                    cell?.lblLikeCount.text = "\(likeCount!)"
                    ////                    cell?.lblCommentCount.text = "\(commentCount!)"
                    ////                    cell?.repost_count.text = "\(repost_count ?? "")"
                    ////                    let liked = "\(like!)"
                    //                    if liked == "1"{
                    //                        //                            cell?.like()
                    //                        cell?.alreadyLiked()
                    //
                    //                    }else{
                    //                        cell?.heartAnimationView?.removeFromSuperview()
                    //                    }
                    //                        print("likedd: ",like!)
                    
                }else{
                    print("likeVideo response msg: ",response?.value(forKey: "msg"))
                }
            }
            
        }
    }
    
    
    @objc func handleLongPress(_ gesture: UITapGestureRecognizer){
        print("long press")
        
        let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
        print("currentVidIP.row",currentVidIP.row)
        let videoObj = videosMainArr[currentVidIP.row]
        let rcvrID = videoObj.videoUserID
    
        
        let vc = VideoPopViewController(nibName: "VideoPopViewController", bundle: nil)
        vc.videoID = videoObj.videoID
        vc.currentVideoUrl = videoObj.videoURL
        vc.receiverID = rcvrID
        vc.NotInterstedDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        
        nav.isNavigationBarHidden =  true
        nav.modalPresentationStyle = .overFullScreen
        
        self.present(nav, animated: false, completion: nil)
        
    }

    func getVideoDuration(from url: URL) -> String? {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        let totalSeconds = CMTimeGetSeconds(duration)
        
        let minutes = Int(totalSeconds / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        
        return formattedDuration
    }
    
}

//MARK: - EXTENSION FOR COLLECTION VIEW

extension MusicHomeScreenViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == musicOptionCollectionView{
            return musicOption.count
        }else{
            return videosMainArr.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == musicOptionCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicOptionsCollectionViewCell", for: indexPath)as! MusicOptionsCollectionViewCell
            
            cell.lblMusic.text = musicOption[indexPath.row].localiz()
            if indexPath.row == 0{
                cell.viewBar.isHidden = false
            }else if indexPath.row == 1{
                cell.viewBar.isHidden = false
            }else{
                cell.viewBar.isHidden = true
            }
            
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicHomeCollectionViewCell", for: indexPath)as! MusicHomeCollectionViewCell
            if indexPath.row == 0 {
                
                

                musicCollectionView.contentInsetAdjustmentBehavior = .never
            }else {
                musicCollectionView.contentInsetAdjustmentBehavior = .scrollableAxes
            }
            
            
            if indexPath.row == videosMainArr.count - 1 {
                musicCollectionView.contentInsetAdjustmentBehavior = .never
            }
            
            cell.delegate = self
            let vidObj = videosMainArr[indexPath.row]
//            currentVidIP = indexPath
            
            if let url = URL(string: vidObj.videoGIF) {
                print("vidObj.videoGIF",url)
                SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                    if let image = image {
                        cell.updateNowPlayingInfo(withTitle: "Smusix", artist: vidObj.username, artwork: image, currentIndex: indexPath.row)
                    } else {
                        print("Error loading image:", error ?? "Unknown error")
                    }
                }
            }
            
            
            if vidObj.followBtn == "follow" {
                cell.btnFollow.setTitle("Follow".localiz(), for: .normal)
            }else{
                cell.btnFollow.setTitle("Following".localiz(), for: .normal)
            }
        
            if let url = URL(string: vidObj.videoGIF) {
                print("vidObj.videoGIF",url)
                SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                    if let image = image {
                        cell.updateNowPlayingInfo(withTitle: "Smusix", artist: vidObj.username, artwork: image, currentIndex: indexPath.row)
                    } else {
                        print("Error loading image:", error ?? "Unknown error")
                    }
                }
            }
            
            cell.videoCount = videosMainArr.count
            let vidString = AppUtility?.detectURL(ipString: vidObj.videoURL)
            let vidURL = URL(string: vidString!)
            let vidDesc = vidObj.description
            cell.set(url: vidURL!)
            
            let userImgPath = AppUtility?.detectURL(ipString: vidObj.userProfile_pic)
            let userImgUrl = URL(string: userImgPath!)
            
            cell.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgProfile.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "noUserImg"))
            
            cell.lblDescription.text = vidDesc
            
            if vidObj.verified == "0"{
                cell.imgVerified.isHidden = true
            }else{
                cell.imgVerified.isHidden = false
            }
            
            let duetVidID = vidObj.duetVideoID
            if duetVidID != "0"{
                cell.videoView.contentMode = .scaleAspectFill
            }else{
                cell.videoView.contentMode = .scaleAspectFill
            }
            
            cell.lblName.text = vidObj.first_name + " " + vidObj.last_name
            
           
            
            cell.btnImage.tag = indexPath.row
            cell.btnImage.addTarget(self, action: #selector(imageButtonPressed(sender:)), for: .touchUpInside)
           
            
            let commentCount = Int("\(vidObj.comment_count)")?.roundedWithAbbreviations //vidObj.comment_count
            let likeCount = Int("\(vidObj.like_count)")?.roundedWithAbbreviations
            let share = Int("\(vidObj.device_token)")?.roundedWithAbbreviations
            
            cell.lblCommentCount.text = "\(commentCount ?? "")"
            cell.lblHeartCount.text = "\(likeCount ?? "")"
            cell.lblShareCount.text = "\(share ?? "")"
            
            cell.btnPlay.addTarget(self, action: #selector(playButtonPressed(sender:)), for: .touchUpInside)
            
            
            cell.btnHeart.addTarget(self, action: #selector(btnLikeTapped(sender:)), for: .touchUpInside)
            cell.btnHeart.tag = indexPath.row
            cell.btnHeart.isUserInteractionEnabled = true
            
            videoID = vidObj.videoID
            videoURL = vidObj.videoURL
            
            
            cell.btnComment.addTarget(self, action: #selector(btnCommentTapped(sender:)), for: .touchUpInside)
            cell.btnComment.tag = indexPath.row
            cell.btnComment.isUserInteractionEnabled = true
            
            
            cell.btnShare.addTarget(self, action: #selector(btnShareTapped(sender:)), for: .touchUpInside)
            cell.btnShare.tag = indexPath.row
            cell.btnShare.isUserInteractionEnabled = true
            
            
            cell.btnFollow.addTarget(self, action: #selector(btnFollowFunc(sender:)), for: .touchUpInside)
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.isUserInteractionEnabled = true
            
            cell.btnTop100.addTarget(self, action: #selector(btnTop100(sender:)), for: .touchUpInside)
            cell.btnTop100.tag = indexPath.row
            cell.btnTop100.isUserInteractionEnabled = true
           
            
            cell.btnForward.addTarget(self, action: #selector(btnForwardButton(sender:)), for: .touchUpInside)
            cell.btnForward.tag = indexPath.row
            cell.btnForward.isUserInteractionEnabled = true
            
            
            cell.btnBackward.addTarget(self, action: #selector(btnBackwardButton(sender:)), for: .touchUpInside)
            cell.btnBackward.tag = indexPath.row
            cell.btnBackward.isUserInteractionEnabled = true
            
            
            cell.lblShareCount.text = share
        
            
            return cell
            
        }
       
    }
    
    @objc func btnForwardButton(sender: UIButton) {
        if !isWorking{
            let nextIndex = sender.tag + 1
            if nextIndex <= videosMainArr.count - 1 {
                self.musicCollectionView.performBatchUpdates(nil, completion: {
                    (result) in
                    self.musicCollectionView.isPagingEnabled = false
                    UIView.animate(withDuration: 0.3, animations: { // Set a shorter duration for the animation
                        self.musicCollectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .bottom, animated: false)
                    }, completion: { _ in
                        
                    })
                    self.musicCollectionView.isPagingEnabled = true
                  

                })
                
                UserDefaults.standard.set(false, forKey: "isFirstTime")
                self.imageView.isHidden = true
            
            } else {
                self.showToast(message: "Next Video is not available".localiz(), font: .boldSystemFont(ofSize: 12.0))
            }
        }
        
    }

    @objc func btnBackwardButton(sender: UIButton) {
        if !isWorking{
            let nextIndex = sender.tag - 1
            if nextIndex >= 0 {
                self.musicCollectionView.performBatchUpdates(nil, completion: {
                    (result) in
                    self.musicCollectionView.isPagingEnabled = false
                    UIView.animate(withDuration: 0.3, animations: { // Set a shorter duration for the animation
                        self.musicCollectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .top, animated: false)
                    }, completion: { _ in
                        
                    })
                    self.musicCollectionView.isPagingEnabled = true
                    
                })
                
                UserDefaults.standard.set(false, forKey: "isFirstTime")
                self.imageView.isHidden = true
            } else {
                self.showToast(message: "Back Video is not available".localiz(), font: .boldSystemFont(ofSize: 12.0))
            }
        }
    }
    
    @objc func btnTop100(sender : UIButton){
        print(sender.tag)
        
        let userID = UserDefaultsManager.shared.user_id
        
        if userID == nil || userID == ""{
            
            loginScreenAppear()
        }else{
           
            if UserDefaultsManager.shared.wallet == "0"{
                self.showToast(message: "you don't have golden disc".localiz(), font: .boldSystemFont(ofSize: 12.0))
            }else{
                let videoObj = videosMainArr[sender.tag]
                self.voteVideo(video_id: videoObj.videoID)
                
            }
           
        }
        
    }
    
    
    //    MARK:- Follow user API
    func voteVideo(video_id:String){
        
        ApiHandler.sharedInstance.voteVideo(user_id: UserDefaultsManager.shared.user_id, video_id: video_id) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userObj = userObjMsg.value(forKey: "User") as! NSDictionary
                    
                    self.showToast(message: "Golden Record Given to Singer".localiz(), font: .boldSystemFont(ofSize: 12.0))
                    self.getUserDetails()
                }else{
                    
                    let msg = response?.value(forKey: "msg") as? String
                    self.showToast(message: msg!.localiz(), font: .boldSystemFont(ofSize: 12.0))
                    self.getUserDetails()
                }
                
            }else{
                
                
            }
        }
    }
    
    
    
    @objc func btnFollowFunc(sender : UIButton){
        print(sender.tag)
        
        let uid = UserDefaultsManager.shared.user_id
        if uid == "" || uid == nil{
            //  showToast(message: "Please Login..", font: .systemFont(ofSize: 12.0))
            loginScreenAppear()
        }else{
            followUserFunc(cellNo: sender.tag)
            print("sender.currentTitle: ",sender.currentTitle)
        
            
        }
    }
    
    
    func followUserFunc(cellNo:Int){
        let videoObj = videosMainArr[cellNo]
        let rcvrID = ccuser_id
        let userID = UserDefaultsManager.shared.user_id
        
        followUser(rcvrID: rcvrID, userID: userID, cellNo: cellNo)
    }
    
    
    //    MARK:- Follow user API
    func followUser(rcvrID:String,userID:String,cellNo : Int){
        
        print("Recid: ",rcvrID)
        print("senderID: ",userID)
        
        
        ApiHandler.sharedInstance.followUser(sender_id: userID, receiver_id: rcvrID) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    
                    let cell = self.musicCollectionView.cellForItem(at: IndexPath(item: cellNo, section: 0)) as? MusicHomeCollectionViewCell
                    //                cell?.playerView.pause()
                    //                cell?.pause()
                    let userObjMsg = response?.value(forKey: "msg") as! NSDictionary
                    let userObj = userObjMsg.value(forKey: "User") as! NSDictionary
                    let followBtn = (userObj.value(forKey: "button") as? String)!
                    
                    if followBtn == "following"{
                        cell?.btnFollow.setTitle(followBtn, for: .normal)
                        
                    }else {
                        cell?.btnFollow.setTitle(followBtn, for: .normal)
                    }
                    
                }else{
                    
                    //                    self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
                }
                
            }else{
                
                //                self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
            }
        }
    }
    
    @objc func btnShareTapped(sender : UIButton) {
        let obj = videosMainArr[sender.tag]
       
        let vc = ShareToViewController(nibName: "ShareToViewController", bundle: nil)
        vc.videoID = videoID
        vc.objToShare.removeAll()
        // vc.videoRepostCount = videoObj.repostCount
        //vc.repostDelegate = self
        vc.objToShare.append(videoURL)
        vc.currentVideoUrl = videoURL
        vc.userID = obj.userID
        vc.NotInterstedDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true)
        
    }
    
    @objc func btnCommentTapped(sender : UIButton) {
        // Do what you want
        
       
        let obj = videosMainArr[sender.tag]
        print("obj user id : ",obj.userID)
        
        //        let obj = self.friends_array[sender.view!.tag] as! Home
        //        self.video_id = obj.v_id
        
        
        let otherUserID = obj.userID
        let userID = UserDefaultsManager.shared.user_id //UserDefaults.standard.string(forKey: "userID")
        
        if userID == nil || userID == ""{
            
            loginScreenAppear()
        }else{
            let myViewController = CommentViewController(nibName: "CommentViewController", bundle: nil)
            
            myViewController.Video_Id = videoID //video_id!
            // myViewController.modalPresentationStyle = .overFullScreen
            myViewController.commentDelegate = self
            let nav = UINavigationController(rootViewController: myViewController)
            nav.modalPresentationStyle = .overFullScreen
            present(nav, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func playButtonPressed(sender: UIButton){
        if !isWorking{
            print("singletapped")
            
            let visiblePaths = self.musicCollectionView.indexPathsForVisibleItems
            for i in visiblePaths  {
                let cell = musicCollectionView.cellForItem(at: i) as? MusicHomeCollectionViewCell
             
                
                if cell!.videoView.state == .playing {
                    cell!.videoView.pause(reason: .userInteraction)
                   
                    //                cell!.btnPlayImg.isHidden = false
                } else {
                    //                cell!.btnPlayImg.isHidden = true
                    cell!.videoView.resume()
                   
                }
                
            }
        }
        
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == musicOptionCollectionView{
            return CGSize(width: collectionView.frame.width / 3.0, height: 55)
        }else{
            return CGSize(width:musicCollectionView.frame.width , height: musicCollectionView.frame.height)

        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == musicOptionCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! MusicOptionsCollectionViewCell
            if indexPath.row == 2{
                self.languageView.isHidden = false
                self.categoryView.isHidden = true
                
               
               
            }else if indexPath.row == 1{
                self.languageView.isHidden = true
                self.categoryView.isHidden = false
                
                if UserDefaultsManager.shared.langauge == "English"{
                    self.categoryView0.isHidden = true
            
                    self.lblCategory2.text = englishCategories[0]
                    self.lblCategory3.text = englishCategories[1]
                    self.lblCategory4.text = englishCategories[2]
                    self.lblCategory5.text = englishCategories[3]
                    self.lblCategory6.text = englishCategories[4]
                    self.lblCategory7.text = englishCategories[5]
//                    self.lblCategory8.text = englishCategories[7]
                    
                    self.btn1.tag = 0
                    self.btn2.tag = 1
                    self.btn3.tag = 2
                    self.btn4.tag = 3
                    self.btn5.tag = 4
                    self.btn6.tag = 5
                    
                    self.categoryView8.backgroundColor = .clear
                    self.lblCategory8.text = ""
                    self.categoryView9.backgroundColor = .clear
                    self.lblCategory9.text = ""
                    
                }else if UserDefaultsManager.shared.langauge == "Spanish"{
                    self.categoryView0.isHidden = false
                    self.lblCategory1.text = spanishCategories[0]
                    self.lblCategory2.text = spanishCategories[1]
                    self.lblCategory3.text = spanishCategories[2]
                    self.lblCategory4.text = spanishCategories[3]
                    self.lblCategory5.text = spanishCategories[4]
                    self.lblCategory6.text = spanishCategories[5]
                    self.lblCategory7.text = spanishCategories[6]
//                    self.lblCategory8.text = spanishCategories[7]
//                    self.lblCategory9.text = spanishCategories[8]
                    self.btn0.tag = 0
                    self.btn1.tag = 1
                    self.btn2.tag = 2
                    self.btn3.tag = 3
                    self.btn4.tag = 4
                    self.btn5.tag = 5
                    self.btn6.tag = 6
                    
                    self.categoryView8.backgroundColor = .clear
                    self.lblCategory8.text = ""
                    self.categoryView9.backgroundColor = .clear
                    self.lblCategory9.text = ""
                    
                    
                }else if UserDefaultsManager.shared.langauge == "German"{
                    self.categoryView0.isHidden = true
//                    self.lblCategory1.text = germanCategories[0]
                    self.lblCategory2.text = germanCategories[0]
                    self.lblCategory3.text = germanCategories[1]
                    self.lblCategory4.text = germanCategories[2]
                    self.lblCategory5.text = germanCategories[3]
                    self.lblCategory6.text = germanCategories[4]
                    self.lblCategory7.text = germanCategories[5]
                    
                    self.btn1.tag = 0
                    self.btn2.tag = 1
                    self.btn3.tag = 2
                    self.btn4.tag = 3
                    self.btn5.tag = 4
                    self.btn6.tag = 5
                    

                    
                    self.categoryView8.backgroundColor = .clear
                    self.lblCategory8.text = ""
                    self.categoryView9.backgroundColor = .clear
                    self.lblCategory9.text = ""
                    
                    
                }else if UserDefaultsManager.shared.langauge == "Italian"{
                    self.categoryView0.isHidden = true
//                    self.lblCategory1.text = italianCategories[0]
                    self.lblCategory2.text = italianCategories[0]
                    self.lblCategory3.text = italianCategories[1]
                    self.lblCategory4.text = italianCategories[2]
                    self.lblCategory5.text = italianCategories[3]
                    self.lblCategory6.text = italianCategories[4]
                    self.lblCategory7.text = italianCategories[5]
                    
                    self.btn1.tag = 0
                    self.btn2.tag = 1
                    self.btn3.tag = 2
                    self.btn4.tag = 3
                    self.btn5.tag = 4
                    self.btn6.tag = 5
                    

            
                    self.categoryView8.backgroundColor = .clear
                    self.lblCategory8.text = ""
                    self.categoryView9.backgroundColor = .clear
                    self.lblCategory9.text = ""
                    
                    
                }else if UserDefaultsManager.shared.langauge == "French"{
                    self.categoryView0.isHidden = false
                    self.lblCategory1.text = frenchCategories[0]
                    self.lblCategory2.text = frenchCategories[1]
                    self.lblCategory3.text = frenchCategories[2]
                    self.lblCategory4.text = frenchCategories[3]
                    self.lblCategory5.text = frenchCategories[4]
                    self.lblCategory6.text = frenchCategories[5]
                    self.lblCategory7.text = frenchCategories[6]
                    
                    self.btn0.tag = 0
                    self.btn1.tag = 1
                    self.btn2.tag = 2
                    self.btn3.tag = 3
                    self.btn4.tag = 4
                    self.btn5.tag = 5
                    self.btn6.tag = 6

                    self.categoryView8.backgroundColor = .clear
                    self.lblCategory8.text = ""
                    self.categoryView9.backgroundColor = .clear
                    self.lblCategory9.text = ""
                    
                }else{
                    self.categoryView0.isHidden = false
                    self.lblCategory1.text = portugueseCategories[0]
                    self.lblCategory2.text = portugueseCategories[1]
                    self.lblCategory3.text = portugueseCategories[2]
                    self.lblCategory4.text = portugueseCategories[3]
                    self.lblCategory5.text = portugueseCategories[4]
                    self.lblCategory6.text = portugueseCategories[5]
                    self.lblCategory7.text = portugueseCategories[6]
                    
                    self.btn0.tag = 0
                    self.btn1.tag = 1
                    self.btn2.tag = 2
                    self.btn3.tag = 3
                    self.btn4.tag = 4
                    self.btn5.tag = 5
                    self.btn6.tag = 6
                    
                    self.categoryView8.backgroundColor = .clear
                    self.lblCategory8.text = ""
                    self.categoryView9.backgroundColor = .clear
                    self.lblCategory9.text = ""
                }
                
                
            }else{
                self.languageView.isHidden = true
                self.categoryView.isHidden = true
                self.isFollowing = true
                if UserDefaultsManager.shared.user_id == ""{
                    self.loginScreenAppear()
                }else{
                    self.getFollowingVideos(startPoint: "0")
                }
            }
            
        }else{
            
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == musicOptionCollectionView{
            
        }else{
            
            if !isBackground {
                let cell1 = cell as? MusicHomeCollectionViewCell //{
    //
                getVideoDetails(ip: indexPath)
    //            self.WatchVideo(video_id: videoID)
    //
                
                let vidObj = videosMainArr[indexPath.row]
                self.WatchVideo(video_id: videoID)
                
                currentVidIP = indexPath
                index123 = currentVidIP
                if let cell = cell as? MusicHomeCollectionViewCell {
                    cell.play(atIndex: indexPath.row)
                    
                
                    if let url = URL(string: vidObj.videoGIF) {
                        print("vidObj.videoGIF",url)
                        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                            if let image = image {
                                cell.updateNowPlayingInfo(withTitle: "Smusix", artist: vidObj.username, artwork: image, currentIndex: indexPath.row)
                            } else {
                                print("Error loading image:", error ?? "Unknown error")
                            }
                        }
                    }
                    
                    
                    if indexPath.row == 1 {
                        UserDefaults.standard.set(false, forKey: "isFirstTime")
                        self.imageView.isHidden = true
                    }
                    
                    
                    
                }
               
                if !videoEmpty{
                  
                    if indexPath.row == videosMainArr.count - 4{
                        
                        self.startPoint += 1
                        print("StartPoint: ",startPoint)
                        
                        if isFollowing == true{
                              self.getFollowingVideos(startPoint: "\(self.startPoint)")
                        }else{
                            self.getAllVideos(startPoint: "\(self.startPoint)", video_type: UserDefaultsManager.shared.category.lowercased(), language: UserDefaultsManager.shared.langauge.lowercased())
                           
                        }
                        
                        print("index@row: ",indexPath.row)
                        current123 = indexPath.row
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MusicHomeCollectionViewCell {
            cell.pause()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { check() }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        check()
    }
    
    func check() {
       // checkPreload()
        checkPlay()
    }
    
   
    func checkPlay() {
        let visibleCells = musicCollectionView.visibleCells.compactMap { $0 as? MusicHomeCollectionViewCell }
        
        guard let lastRow = musicCollectionView.indexPathsForVisibleItems.last?.row else { return }
        print("lastRow",lastRow)
    
        if lastRow == videosMainArr.count - 1 {
            musicCollectionView.contentInsetAdjustmentBehavior = .never
        }
        
       
        guard visibleCells.count > 0 else { return }
        
        let visibleFrame = CGRect(x: 0, y: 0, width: musicCollectionView.bounds.width, height: musicCollectionView.bounds.height)
        
        let visibleCell = visibleCells
            .filter { visibleFrame.intersection($0.frame).height >= $0.frame.height / 2 }
            .first
        
        visibleCell?.play(atIndex: currentVidIP.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
   
    func remove(index: Int) {
        videosMainArr.remove(at: index)
        
        let indexPath = IndexPath(row: index, section: 0)
        musicCollectionView.performBatchUpdates({
            self.musicCollectionView.deleteItems(at: [indexPath])
        }, completion: {
            (finished: Bool) in
            self.musicCollectionView.reloadItems(at: self.musicCollectionView.indexPathsForVisibleItems)
        })
    }
    
    
    //    Mark:- On audio on mute button
    func setupAudio() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
}

