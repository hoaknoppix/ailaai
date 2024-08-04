//
//  JoinRequestResponse.swift
//  AiLaAi
//
//  Created by Hoa Tran on 8/2/24.
//  Copyright © 2024 orgName. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct JoinRequestResponse: Codable {
    let id, createdAt, person, group: String
    let message: String
}
