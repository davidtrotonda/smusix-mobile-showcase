
import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import FirebaseCore
import GoogleSignIn
import FirebaseMessaging
import UserNotifications
import LanguageManager_iOS



let NextLevelAlbumTitle = "NextLevel"


@main
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate,MessagingDelegate{
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
//
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        
        
        
        LanguageManager.shared.defaultLanguage = .deviceLanguage
        
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
       
        setupPushNotification()
        registerNotificationCategories()
        
        
        notificationConfig(application)
        return true
    }
    
    private func setupPushNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
                print("Notifications permission granted.")
            } else {
                print("Failed to Notifications permission with error: \(String(describing: error?.localizedDescription)).")
            }
        }
    }
    
    private func registerNotificationCategories() {
        let moreAction = UNNotificationAction( identifier: "watch.more",
                                               title: "Watch More",
                                               options: [.foreground])
        let shareVideoAction = UNNotificationAction( identifier: "share",
                                                     title: "Share",
                                                     options: [.foreground])
        let videoCategory = UNNotificationCategory( identifier: "news_video_notification",
                                                    actions: [moreAction, shareVideoAction],
                                                    intentIdentifiers: [],
                                                    options: [])
        UNUserNotificationCenter.current().setNotificationCategories([videoCategory])
    }
    
    func notificationConfig(_ application: UIApplication) {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        
        UNUserNotificationCenter.current().delegate = self // Ensure this class conforms to UNUserNotificationCenterDelegate
        
        if #available(iOS 10.0, *) {
            // For iOS 10 and above, request notification authorization
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                if let error = error {
                    print("Error requesting notification authorization: \(error)")
                }
            }
        } else {
            // For iOS 9 and below, register for notification settings
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
       
        // Set up Firebase Messaging
        Messaging.messaging().delegate = self // Ensure this class conforms to MessagingDelegate
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().subscribe(toTopic: "topicEventSlotUpdated") { error in
            if let error = error {
                print("Error subscribing to topic: \(error)")
            }
        }
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                UserDefaultsManager.shared.device_token = token
                AppUtility?.saveObject(obj: token, forKey: "DeviceToken")
            }
        }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //        return ApplicationDelegate.shared.application(
    //            app,
    //            open: url,
    //            options: options
    //        )
    //    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String,
            annotation: nil
        )
    }
    
//    func openViewController() {
//
//    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//    let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
//    tabBarController.selectedIndex = 1
//    tabBarController.pushViewController(tabBarController, animated: true)
//    self.window = UIWindow.init(frame: UIScreen.main.bounds)
//    self.window?.rootViewController = tabBarController
//    self.window?.makeKeyAndVisible()
//    }
    
  
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("app is closed")
        NotificationCenter.default.post(name: .appIsClosed, object: "appIsClosed", userInfo: [:])
       
    }
    
    
    
    
    //    func application(
    //      _ app: UIApplication,
    //      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    //    ) -> Bool {
    //        var handled: Bool
    //
    //        handled = GIDSignIn.sharedInstance.handle(url)
    //        if handled {
    //            return true
    //        }
    //
    //        // Handle other custom URL types.
    //
    //        // If not handled by this app, return false.
    //        return false
    //    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //
    //
    //
    //        let handled=ApplicationDelegate.shared.application(
    //            app,
    //            open: url,
    //            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
    //            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    //        )
    //
    //        return GIDSignIn.sharedInstance().handle(url)  || handled
    //    }
    //
    //    @available(iOS 13.0, *)
    //    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    //        guard let url = URLContexts.first?.url else {
    //            return
    //        }
    //
    //        ApplicationDelegate.shared.application(
    //            UIApplication.shared,
    //            open: url,
    //            sourceApplication: nil,
    //            annotation: [UIApplication.OpenURLOptionsKey.annotation]
    //        )
    //    }
    //
    //
    //    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    //        if (error == nil) {
    //            // Perform any operations on signed in user here.
    //            let userId = user.userID                  // For client-side use only!
    //            let idToken = user.authentication.idToken // Safe to send to the server
    //            let fullName = user.profile.name
    //            let givenName = user.profile.givenName
    //            let familyName = user.profile.familyName
    //            let email = user.profile.email
    //            // ...
    //        } else {
    //            print("\(error.localizedDescription)")
    //        }
    //    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
    //    static func getWindow() -> UIWindow? {
    //        return UIApplication.shared.keyWindow
    //    }
    //
    //    static func resetViewController() {
    //        let window = getWindow()
    //
    //        let controller = TabbarViewController() //...  /// Instantiate your inital `UIViewController`
    //
    //        window?.rootViewController = controller
    //        window?.makeKeyAndVisible()
    //    }
}


extension AppDelegate{
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { (token, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error.localizedDescription)")
                UserDefaults.standard.set("NuLL", forKey:"DeviceToken")
            } else if let token = token {
                print("Token is \(token)")
                UserDefaultsManager.shared.device_token = token
                UserDefaults.standard.set(token, forKey:"DeviceToken")
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingMessageInfo) {
        guard let data = try? JSONSerialization.data(withJSONObject: remoteMessage, options: .prettyPrinted),
              let prettyPrinted = String(data: data, encoding: .utf8) else {
            return
        }
        print(remoteMessage)
        let res = remoteMessage
        print(res)
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
    }
    
    // Firebase notification received
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        print("Handle push from foreground, received: \n \(notification.request.content)")
//        print("Handle push from Active state, received: \n \(notification.request.content)")
//        print(notification.request.content.userInfo)
        
        let type  = notification.request.content.userInfo[AnyHashable("gcm.notification.type")] as? String
        let request_id  = notification.request.content.userInfo[AnyHashable("gcm.notification.request_id")] as? String
        let receiver_id  = notification.request.content.userInfo[AnyHashable("gcm.notification.user_id")] as? String
        let receiver_name  = notification.request.content.userInfo[AnyHashable("gcm.notification.name")] as? String
//        print(type)
        if type == "single_message"{
            
        }else{
            //            self.activeRequestAPI()
        }
        /*
         do {
         let notification = try MTNotificationBuilder.build(from: notification.request.content.userInfo)
         print(notification.alert)
         print(notification.body)
         print(notification.title)
         
         if notification.title == "Paid"{
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "paidNoti"), object: nil)
         }
         } catch let error {
         print(error)
         }
         */
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("Handle tapped push from background, received: \n \(response.notification.request.content)")
//        print(response.notification.request.content.userInfo)
        let userInfo = response.notification.request.content.userInfo as! [String:Any]
        print("Handle tapped push from background, received: \n \(response.notification.request.content)")
        let type  = userInfo["type"] as? String
        let request_id  = userInfo["gcm.notification.request_id"] as? String
        let receiver_id  = userInfo["gcm.notification.user_id"] as? String
        let receiver_name  = userInfo["gcm.notification.name"] as? String
//        print(userInfo)
        if type == "single_message"{
            
            let storyMain = UIStoryboard(name: "Main", bundle: nil)
            //            if let rootViewController = UIApplication.topViewController() {
            //                let vc =  storyMain.instantiateViewController(withIdentifier: "newChatViewController") as! newChatViewController
            //                vc.modalPresentationStyle = .overFullScreen
            //                vc.isNotification =  false
            //                vc.requestID = request_id ?? "0"
            //                vc.receiverID = receiver_id ?? "0"
            //                vc.receiverName = receiver_name ?? "unknown"
            //                rootViewController.navigationController?.pushViewController(vc, animated: true)
            //            }
        }else{
            //            self.activeRequestAPI()
        }
        
        
        completionHandler()
        
//        if let data = response.notification.request.content.userInfo as? [String: Any] {
//            print("Notification data: \(data) and action: \(response.actionIdentifier)")
//        }
//        completionHandler()
        
        
    }
}
