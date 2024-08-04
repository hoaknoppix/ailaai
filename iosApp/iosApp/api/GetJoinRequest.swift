//
//  GetJoinRequest.swift
//  AiLaAi
//
//  Created by Hoa Tran on 8/2/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct GetJoinRequest: Codable {
    let person: Person
    let joinRequest: JoinRequestResponse
}

//// MARK: - JoinRequest
//struct JoinRequest: Codable {
//    let id, createdAt, person, group: String
//    let message: String
//}
//
//// MARK: - RequestPerson
//struct RequestPerson: Codable {
//    let id, createdAt, name, photo: String
//    let geo: [Double]
//    let seen: String
//}
