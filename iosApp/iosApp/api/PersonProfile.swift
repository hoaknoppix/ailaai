//
//  PersonProfile.swift
//  AiLaAi
//
//  Created by Hoa Tran on 7/17/24.
//  Copyright © 2024 orgName. All rights reserved.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let personProfile = try? JSONDecoder().decode(PersonProfile.self, from: jsonData)

import Foundation

// MARK: - PersonProfile
struct PersonProfile: Codable {
    let person: PersonElement
    let profile: Profile
    let stats: Stats
}

// MARK: - Person
struct PersonElement: Codable {
    let id, createdAt, name: String
    let photo: String?
    let geo: [Double]?
    let seen: String
}

// MARK: - Profile
struct Profile: Codable {
    let id, createdAt, person: String
    let photo: String?
    let about: String?
}

// MARK: - Stats
struct Stats: Codable {
    let friendsCount, cardCount, storiesCount, subscriberCount: Int
}
