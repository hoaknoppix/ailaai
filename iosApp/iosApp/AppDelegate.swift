//
//  AppDelegate.swift
//  AiLaAi
//
//  Created by Hoa Tran on 1/10/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import UserNotifications
import UIKit
import notiExtend

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isNotified : Bool?
    
    func tapOnNotification() -> Bool {
        if (isNotified == true) {
            isNotified = false
            return true
        }
        return false
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var globalVariables = GlobalVariables()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        registerForPushNotifications()
        return true
    }
    
    private func registerForPushNotifications() {
        print("Registering for Push Notifications")
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            /* some code */
        }
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // 1. Check to see if permission is granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        UserDefaults.standard.register(defaults: ["notificationGroupId": "Unknown"])
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension AppDelegate : GetMessagesSuccessProtocol {
    func execute(messages: [MessageDTO]) {
        globalVariables.messages = messages
        globalVariables.uiMessages = globalVariables.messages.map {
            SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
        }
            .sorted {
            $0.createdAt < $1.createdAt
        }
//        viewMessages = true
        print("Messages are loaded!!!")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification)
        let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications")
        var senderId = userDf!.object(forKey: "notificationSenderId") as! String
        if (globalVariables.userInfo?.id != senderId) {
            completionHandler([.list, .banner])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
      ) {
          print("Hello this is me you are looking for")
          AppState.shared.isNotified = true
          let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications")
          var groupId = userDf!.object(forKey: "notificationGroupId") as! String
          globalVariables.group = globalVariables.groups.first(where: {$0.group.id == groupId})
          SwiftAPI.getMesssages(token: globalVariables.token, groupId: groupId, onSuccess: self)
//          UserDefaults.standard.setValue("Hello", forKey: "Tmp")
//          print(UserDefaults.standard)
//        // 1
//        let userInfo = response.notification.request.content.userInfo
//        
//        // 2
//        if
//          let aps = userInfo["aps"] as? [String: AnyObject],
//          let newsItem = NewsItem.makeNewsItem(aps) {
//          (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//          
//          // 3
//          if response.actionIdentifier == Identifiers.viewAction,
//            let url = URL(string: newsItem.link) {
//            let safari = SFSafariViewController(url: url)
//            window?.rootViewController?
//              .present(safari, animated: true, completion: nil)
//          }
//        }
//        
        // 4
        completionHandler()
      }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Ready....")
        globalVariables.deviceToken = deviceToken.hexEncodedString()
        print(deviceToken.hexEncodedString())
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error....")
        print(error)
    }
}
