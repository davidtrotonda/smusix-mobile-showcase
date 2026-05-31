import UIKit

class UploadViewController: UIViewController {
    
    
    //MARK:- OUTLET
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarView: GradientHorizontalProgressBar!
    @IBOutlet weak var lblUpload: UILabel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressBar.transform = CGAffineTransform(scaleX: 1, y: 1.0)
        self.progressBar.layer.cornerRadius = 4
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadVideo(notify:)), name: NSNotification.Name(rawValue: "uploadVideo"), object: nil)
        
    }
    
    @objc func uploadVideo(notify:Notification){
        let gradient = UIColor(named: "theme")!
        let obj = notify.object as! Double
        
        print("Uploading progress bar:",obj)
        self.progressBar.progress = Float(CGFloat(obj))
        self.lblUpload.text = "Uploading \(Int(obj*100))%"
    }
    
  
    
  
}
