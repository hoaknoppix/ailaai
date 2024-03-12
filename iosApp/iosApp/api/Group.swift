// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let groups = try? JSONDecoder().decode(Groups.self, from: jsonData)

import Foundation

// MARK: - Group
struct Group: Codable {

    
    let group: GroupClass
    let members: [MemberElement]
    let latestMessage: LatestMessage?
}

// MARK: - GroupClass
struct GroupClass: Codable {
    let id, createdAt: String
    let name: String?
    let seen: String
    let description: String?
    let groupOpen: Bool?
    let photo: String?

    enum CodingKeys: String, CodingKey {
        case id, createdAt, name, seen, description, photo
        case groupOpen = "open"
    }
}

// MARK: - LatestMessage
struct LatestMessage: Codable {
    let id, createdAt, group, member: String
    let text: String?
    let attachment: String?
    let attachments: JSONNull?
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
    let hide: Bool?
    let gone: JSONNull?
    let host, snoozed: Bool?
    let snoozedUntil: JSONNull?
}

// MARK: - Person
struct Person: Codable {
    let id, createdAt: String
    let name, photo: String?
    let geo: JSONNull?
    let inviter: String?
    let seen: String
    let language: String?
    let source: JSONNull?
}

typealias Groups = [Group]

// MARK: - Encode/decode helpers

class JSONNull: Codable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
