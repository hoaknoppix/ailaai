// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let message = try? JSONDecoder().decode(Message.self, from: jsonData)

import Foundation

// MARK: - MessageElement
struct MessageDTO: Codable {
    let id, createdAt, group, member: String
    let text, attachment: String?
    let attachments: [String]?
}

// MARK: - Encode/decode helpers

struct AttachmentDTO: Codable, Hashable {
    let photo: String?
    let audio: String?
    let photos: [String]?
    let videos: [String]?
    let sticker: String?
    let message: String?
    let type: String?

    public static func == (lhs: AttachmentDTO, rhs: AttachmentDTO) -> Bool {
        return lhs.photo == rhs.photo
    }

    public var hashValue: Int {
        return 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
