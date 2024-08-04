//
//  UserProfile.swift
//  AiLaAi
//
//  Created by Hoa Tran on 6/16/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct UserProfile: Codable {
    let id, createdAt, person: String
    let photo: String?
    let about: String?
}
