// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - WelcomeElement
struct Group: Codable {
    let group: GroupClass
    let members: [MemberElement]
    let cardCount: Int
    let latestMessage: LatestMessage?
}

// MARK: - Group
struct GroupClass: Codable {
    let id, createdAt: String
    let name, photo: String?
    let seen: String
    let description: String?
    let categories: [String]?
    let groupOpen: Bool?
    let config: Config?
    let background: String?

    enum CodingKeys: String, CodingKey {
        case id, createdAt, name, photo, seen, description, categories
        case groupOpen = "open"
        case config, background
    }
}

// MARK: - Config
struct Config: Codable {
}

// MARK: - LatestMessage
struct LatestMessage: Codable {
    let id, createdAt, group, member: String
    let text: String?
    let attachments: [String]?
    let attachment: String?
}

// MARK: - MemberElement
struct MemberElement: Codable {
    let person: Person
    let member: MemberMember
}

// MARK: - MemberMember
struct MemberMember: Codable {
    let id, createdAt, from, to: String
    let seen: String?
    let host, hide, snoozed: Bool?
}

// MARK: - Person
struct Person: Codable {
    let id, createdAt: String
    let name, photo, inviter: String?
    let seen: String
    let language: Language?
}

enum Language: String, Codable {
    case vi = "vi"
}

//typealias Group = [GroupElement]
