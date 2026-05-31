import UIKit
import LanguageManager_iOS

class AppLanguageViewController: UIViewController {
    
    var languageArr = ["English", "Spanish", "German", "Italian", "French", "Portuguese"]

    
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var appLanguageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        lblTitle.text = "App Language".localiz()
        appLanguageTableView.delegate = self
        appLanguageTableView.dataSource = self
        appLanguageTableView.register(UINib(nibName: "AppLanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "AppLanguageTableViewCell")
        
    }
    
    
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
//MARK:- EXTENSION TABLE VIEW

extension AppLanguageViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppLanguageTableViewCell", for: indexPath) as! AppLanguageTableViewCell
        
        cell.lbl.text = languageArr[indexPath.row]
        
        
        // Check if the current row represents the selected language
            if LanguageManager.shared.currentLanguage == .es && languageArr[indexPath.row] == "Spanish" {
                cell.accessoryType = .checkmark
                cell.accessoryView?.tintColor = UIColor(named: "theme")
            } else if LanguageManager.shared.currentLanguage == .en && languageArr[indexPath.row] == "English" {
                cell.accessoryType = .checkmark
                cell.accessoryView?.tintColor = UIColor(named: "theme")
            } else if LanguageManager.shared.currentLanguage == .de && languageArr[indexPath.row] == "German" {
                cell.accessoryType = .checkmark
                cell.accessoryView?.tintColor = UIColor(named: "theme")
            } else if LanguageManager.shared.currentLanguage == .it && languageArr[indexPath.row] == "Italian" {
                cell.accessoryType = .checkmark
                cell.accessoryView?.tintColor = UIColor(named: "theme")
            } else if LanguageManager.shared.currentLanguage == .fr && languageArr[indexPath.row] == "French" {
                cell.accessoryType = .checkmark
                cell.accessoryView?.tintColor = UIColor(named: "theme")
            } else if LanguageManager.shared.currentLanguage == .ptPT && languageArr[indexPath.row] == "Portuguese" {
                cell.accessoryType = .checkmark
                cell.accessoryView?.tintColor = UIColor(named: "theme")
            }else{
                cell.accessoryType = .none
                cell.accessoryView?.tintColor = .clear
            }
        
        
        
       
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let selectedLanguage = languageArr[indexPath.row]
        
        
        if selectedLanguage == "Spanish" {
            UserDefaultsManager.shared.language_code = "es"
            UserDefaultsManager.shared.langauge = "Spanish"
            self.addLanguageAPI(language: selectedLanguage.lowercased())
            // Change the language
            LanguageManager.shared.setLanguage(language: .es) { title -> UIViewController in
              print("title of the scene: \(title ?? "")")
              // The view controller that you want to show after changing the language
              return self.viewControllerToShow()
            } animation: { view in
              // Do custom animation
              view.transform = CGAffineTransform(scaleX: 2, y: 2)
              view.alpha = 0
            }
        } else if selectedLanguage == "English" {
            UserDefaultsManager.shared.language_code = "en"
            // Change the language
            UserDefaultsManager.shared.langauge = "English"
            self.addLanguageAPI(language: selectedLanguage.lowercased())
            LanguageManager.shared.setLanguage(language: .en) { title -> UIViewController in
              print("title of the scene: \(title ?? "")")
              // The view controller that you want to show after changing the language
              return self.viewControllerToShow()
            } animation: { view in
              // Do custom animation
              view.transform = CGAffineTransform(scaleX: 2, y: 2)
              view.alpha = 0
            }
        } else if selectedLanguage == "German" {
            UserDefaultsManager.shared.language_code = "de"
            UserDefaultsManager.shared.langauge = "German"
            self.addLanguageAPI(language: selectedLanguage.lowercased())
            LanguageManager.shared.setLanguage(language: .de) { title -> UIViewController in
              print("title of the scene: \(title ?? "")")
              // The view controller that you want to show after changing the language
              return self.viewControllerToShow()
            } animation: { view in
              // Do custom animation
              view.transform = CGAffineTransform(scaleX: 2, y: 2)
              view.alpha = 0
            }
        }else if selectedLanguage == "Italian" {
            UserDefaultsManager.shared.language_code = "it"
            UserDefaultsManager.shared.langauge = "Italian"
            self.addLanguageAPI(language: selectedLanguage.lowercased())
            LanguageManager.shared.setLanguage(language: .it) { title -> UIViewController in
              print("title of the scene: \(title ?? "")")
              // The view controller that you want to show after changing the language
              return self.viewControllerToShow()
            } animation: { view in
              // Do custom animation
              view.transform = CGAffineTransform(scaleX: 2, y: 2)
              view.alpha = 0
            }
        }else if selectedLanguage == "French" {
            UserDefaultsManager.shared.language_code = "fr"
            UserDefaultsManager.shared.langauge = "French"
            self.addLanguageAPI(language: selectedLanguage.lowercased())
            LanguageManager.shared.setLanguage(language: .fr) { title -> UIViewController in
              print("title of the scene: \(title ?? "")")
              // The view controller that you want to show after changing the language
              return self.viewControllerToShow()
            } animation: { view in
              // Do custom animation
              view.transform = CGAffineTransform(scaleX: 2, y: 2)
              view.alpha = 0
            }
        }
        else if selectedLanguage == "Portuguese" {
            UserDefaultsManager.shared.language_code = "pt"
            UserDefaultsManager.shared.langauge = "Portuguese"
            self.addLanguageAPI(language: selectedLanguage.lowercased())
            LanguageManager.shared.setLanguage(language: .ptPT) { title -> UIViewController in
              print("title of the scene: \(title ?? "")")
              // The view controller that you want to show after changing the language
              return self.viewControllerToShow()
            } animation: { view in
              // Do custom animation
              view.transform = CGAffineTransform(scaleX: 2, y: 2)
              view.alpha = 0
            }
        }
       
    }
    
    private func viewControllerToShow() -> UIViewController {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      return storyboard.instantiateInitialViewController()!
    }
    
    
    func addLanguageAPI(language: String){
        ApiHandler.sharedInstance.editProfile(isPhoneChange: true, isEditProfile: false, isLanguage: true, username: "", user_id: UserDefaultsManager.shared.user_id, first_name: "", last_name: "", gender: "", website: "", bio: "", dob: "", privateKey: "", phone: "",language: language) { (isSuccess, resp) in
            if isSuccess{
                if resp?.value(forKey: "code") as! NSNumber == 200{
                 print("test45454",resp?.value(forKey: "msg"))
                    
                }else{
                   
                }
            }
        }
        
    }
    
    
}
