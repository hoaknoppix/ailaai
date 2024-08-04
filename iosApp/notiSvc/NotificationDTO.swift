//
//  Notification.swift
//  AiLaAi
//
//  Created by Hoa Tran on 2/5/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

// MARK: - Notification
struct NotificationDTO: Codable {
    let action: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let type: String
    let group, person: NotificationElement
    let message: MessageNotification?
    let event: String?
    let details: DetailsElement?
    let show: Bool?
}

// MARK: - Group
struct NotificationElement: Codable {
    let id: String
    let name: String?
}

// MARK: - Message
struct MessageNotification: Codable {
    let text: String?
    let attachment: String?
}

// MARK: - Details
struct  DetailsElement: Codable {
    let invitor: InvitorElement
}

// MARK: - Invitor
struct InvitorElement: Codable {
    let id: String
    let name: String
}
