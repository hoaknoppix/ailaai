//
//  UserInfo.swift
//  iosApp
//
//  Created by Hoa Tran on 1/4/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct UserInfo: Codable {
    let id, createdAt, name: String
    let photo: String?
    let geo: [Double]?
    let inviter: String?
    let seen: String
    let language, source: String?
}

