//
//  NotificationViewController.swift
//  notiExtend
//
//  Created by Hoa Tran on 2/5/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
//        self.label?.text = "You have a message"
    }

}
