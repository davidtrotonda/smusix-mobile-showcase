import UIKit
import WebKit
import LanguageManager_iOS
class TutorialViewController: UIViewController,UIWebViewDelegate,WKNavigationDelegate {
    
    @IBOutlet var wkwebView: WKWebView!
    
    
    var myUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if LanguageManager.shared.deviceLanguage == .es {
            self.myUrl = "https://smusix.com/politica-de-privacidad/"
        }else if LanguageManager.shared.deviceLanguage == .en {
            self.myUrl = "https://smusix.com/privacy-policy/"
        }else if LanguageManager.shared.deviceLanguage == .de {
            self.myUrl = "https://smusix.com/datenschutzbestimmungen/"
        }else if LanguageManager.shared.deviceLanguage == .it {
            self.myUrl = "https://smusix.com/informativa-sulla-privacy/"
        }else if LanguageManager.shared.deviceLanguage == .fr {
            self.myUrl = "https://smusix.com/politique-de-confidentialite/"
        }else if LanguageManager.shared.deviceLanguage == .ptPT {
            self.myUrl = "https://smusix.com/politica-de-privacidade/"
        }
        let request = URLRequest(url: URL(string: myUrl)!)
        self.navigationController?.isNavigationBarHidden = true
        wkwebView?.navigationDelegate = self
        
        wkwebView?.load(request)
        wkwebView.scalesLargeContentImage = false
        wkwebView.showsLargeContentViewer = true
        wkwebView.isMultipleTouchEnabled = false

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDefaults.standard.set(true, forKey: "isFirstTime")
        UserDefaultsManager.shared.darkMode = "dark"
        
        if LanguageManager.shared.deviceLanguage == .es{
            
            UserDefaultsManager.shared.langauge = "Spanish"
            UserDefaultsManager.shared.category = "All"
        } else if LanguageManager.shared.deviceLanguage == .en {
            
            UserDefaultsManager.shared.langauge = "English"
            UserDefaultsManager.shared.category = "All"
        }else if LanguageManager.shared.deviceLanguage == .it {
            UserDefaultsManager.shared.langauge = "Italian"
            UserDefaultsManager.shared.category = "Tutti"
        }else if LanguageManager.shared.deviceLanguage == .ptPT {
            UserDefaultsManager.shared.langauge = "Portuguese"
            UserDefaultsManager.shared.category = "Todos"
        }else  if LanguageManager.shared.deviceLanguage == .de {
            UserDefaultsManager.shared.langauge = "German"
            UserDefaultsManager.shared.category = "Alle"
        }else if LanguageManager.shared.deviceLanguage == .fr {
            UserDefaultsManager.shared.langauge = "French"
            UserDefaultsManager.shared.category = "Tous"
        }
        
        
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                UIApplication.shared.isStatusBarHidden = false
                UIApplication.shared.statusBarStyle = .lightContent
            }
            else {
                UIApplication.shared.isStatusBarHidden = false
                UIApplication.shared.statusBarStyle = .darkContent
            }
        }
    }


    @IBAction func agreeButtonPressed(_ sender: UIButton) {
        
        let myViewController = TermsViewController(nibName: "TermsViewController", bundle: nil)
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print(#function)

        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
       
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: { result, error in
            if let userAgent = result as? String {
                print(userAgent)

               
            }
        })
    }
    
    
}
