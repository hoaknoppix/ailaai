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
import SwiftUI
import AVFoundation

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isNotified : Bool?
    @Published var isLoaded: Bool = false
    
    func tapOnNotification() -> Bool {
        if (isNotified == true) {
            isNotified = false
            return true
        }
        return false
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, GetProfileSuccessProtocol, GetUserInfoSuccessProtocol, GetGroupsSuccessProtocol {
    var currentGroupId: String = ""

    func applicationWillTerminate(_ application: UIApplication) {
        if let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications") {
            userDf.set(true, forKey: "isTerminated")
        }
    }
    func execute(groups: [Group]) {
        print("Groups are loaded")
        globalVariables.groups = groups
        groups.forEach { group in
            group.members.forEach { m in
                let person = m.person
                let member = m.member
                if (globalVariables.personByGroup[group.group.id] == nil) {
                    globalVariables.personByGroup[group.group.id] = [:]
                }
                globalVariables.personByGroup[group.group.id]![member.id] = person
                
                if (globalVariables.memberByPerson[group.group.id] == nil) {
                    globalVariables.memberByPerson[group.group.id] = [:]
                }
                globalVariables.memberByPerson[group.group.id]![person.id] = member
                if (!globalVariables.userFriends.contains(m.person) && (m.person.id != globalVariables.userInfo?.id)) {
                    globalVariables.userFriends.insert(m.person)
                }
            }
        }
        if (groups.contains(where: { g in
            g.group.id == currentGroupId
        })) {
            SwiftAPI.getMesssages(token: globalVariables.token, groupId: currentGroupId, onSuccess: self)
        }
    }
    
    func execute(userInfo: UserInfo) {
        globalVariables.userInfo = userInfo
        AppState.shared.isLoaded = (globalVariables.userInfo != nil && globalVariables.userProfile != nil)
    }
    
    func execute(userProfile: UserProfile) {
        globalVariables.userProfile = userProfile
        AppState.shared.isLoaded = (globalVariables.userInfo != nil && globalVariables.userProfile != nil)
    }
    
    
    var globalVariables = GlobalVariables()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
        globalVariables.token = UserDefaults.standard.string(forKey: "token") ?? ""
        if (globalVariables.token != "") {
            SwiftAPI.getUserProfile(token: globalVariables.token, onSuccess: self)
            SwiftAPI.getUserInfo(token: globalVariables.token, onSuccess: self)
        }
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
        var sortedMessages = messages.sorted {
            $0.createdAt < $1.createdAt
        }
        print("Get\(sortedMessages)")
        let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications")
        let groupId = userDf!.object(forKey: "notificationGroupId") as! String
        if groupId == globalVariables.group?.group.id && globalVariables.isAtChatView {
            while !sortedMessages.isEmpty {
                var tmp = globalVariables.uiMessages.count - 1
                if let message = sortedMessages.first {
//                    globalVariables.messages.append(lastMessage)
                    let uiMessage = SwiftAPI.getUIMessage(message: message, globalVariables: globalVariables)
                    if (!globalVariables.uiMessages.contains(where: { m in
                        m.id == uiMessage.id || uiMessage.user.isCurrentUser
                    })) {
                        var i = tmp
                        while (i >= 0) {
                            if globalVariables.uiMessages[i].createdAt < uiMessage.createdAt {
                                break
                            }
                            i = i - 1
                        }
                        if (!globalVariables.uiMessages.contains(where: { m in
                            m.id == uiMessage.id
                        })) {
                            globalVariables.uiMessages.insert(uiMessage, at: i + 1)
                        }
                        tmp = i
                    }
                }
                sortedMessages.removeFirst()
            }
        } else {
//            globalVariables.uiMessages = []
//            globalVariables.uiMessages.removeAll()
            while !sortedMessages.isEmpty {
                if let message = sortedMessages.first {
                    let uiMessage = SwiftAPI.getUIMessage(message: message, globalVariables: globalVariables)
                    globalVariables.uiMessages.append(uiMessage)
                }
                sortedMessages.removeFirst()
            }
            globalVariables.group = globalVariables.groups.first(where: {$0.group.id == groupId})
//            globalVariables.uiMessages = sortedMessages.map {
//                SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
//            }
        }
//
//        globalVariables.messages = messages
//        globalVariables.uiMessages = globalVariables.messages.map {
//            SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
//        }
//            .sorted {
//            $0.createdAt < $1.createdAt
//        }
////        viewMessages = true
//        print("Messages are loaded!!!")
        if (!globalVariables.isAtChatView) {
            AppState.shared.isNotified = true
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification)
        if let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications") {
            if let senderId = userDf.object(forKey: "notificationSenderId") as? String, let groupId = userDf.object(forKey: "notificationGroupId") as? String, let action = userDf.object(forKey: "notificationAction") as? String {
                if globalVariables.userInfo?.id != senderId {
                    if (action == "Message") {
                        if !globalVariables.isAtChatView || groupId != globalVariables.group?.group.id {
                            completionHandler([.list, .banner])
                        } else {
                            if (globalVariables.groups.contains(where: { g in
                                g.group.id == groupId
                            })) {
                                SwiftAPI.getMesssages(token: globalVariables.token, groupId: groupId, onSuccess: self)
                            } else {
                                currentGroupId = groupId
                                SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                            }
                        }
                    }
                   else if (action == "Group") {
                       completionHandler([.list, .banner])
                   } else {
                       completionHandler([.list, .banner])
                   }
                }
                
//                if (globalVariables.isAtChatView && globalVariables.group?.group.id == groupId && globalVariables.userInfo?.id != senderId) {
//                    if (action == "Message" || action == "Group") {
//                        if (globalVariables.groups.contains(where: { g in
//                            g.group.id == groupId
//                        })) {
//                            SwiftAPI.getMesssages(token: globalVariables.token, groupId: groupId, onSuccess: self)
//                        } else {
//                            currentGroupId = groupId
//                            SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
//                        }
//                    }
//                } else if (globalVariables.userInfo != nil && globalVariables.userInfo?.id != senderId) {
//                    completionHandler([.list, .banner])
//                }
            }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
      ) {
          print("Hello this is me you are looking for")
          if let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications") {
              if let senderId = userDf.object(forKey: "notificationSenderId") as? String, let groupId = userDf.object(forKey: "notificationGroupId") as? String, let action = userDf.object(forKey: "notificationAction") as? String {
                  //          SwiftAPI.getUserInfo(token: globalVariables.token, onSuccess: self)
                  //          SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                  if action == "Message" {
                      globalVariables.uiMessages.removeAll()
                      if (globalVariables.groups.contains(where: { g in
                          g.group.id == groupId
                      })) {
                          SwiftAPI.getMesssages(token: globalVariables.token, groupId: groupId, onSuccess: self)
                      } else {
                          currentGroupId = groupId
                          SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                      }
                  }  else if (action == "Group") {
                      if (globalVariables.groups.contains(where: { g in
                          g.group.id == groupId
                      })) {
                          SwiftAPI.getMesssages(token: globalVariables.token, groupId: groupId, onSuccess: self)
                      } else {
                          currentGroupId = groupId
                          SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                      }
                  }
//                  SwiftAPI.getMesssages(token: globalVariables.token, groupId: groupId, onSuccess: self)
              }
          }
          
          
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
        if let userDf = UserDefaults(suiteName: "group.ailaai.pushnotifications") {
            userDf.set(false, forKey: "isTerminated")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error....")
        print(error)
    }
}
