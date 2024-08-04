// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let message = try? JSONDecoder().decode(Message.self, from: jsonData)

import Foundation

// MARK: - MessageElement
struct MessageDTO: Codable, Hashable {
    let id, createdAt, group, member: String
    let text, attachment: String?
    let attachments: [String]?
    public static func == (lhs: MessageDTO, rhs: MessageDTO) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(photo)
        hasher.combine(audio)
        hasher.combine(photos)
        hasher.combine(videos)
        hasher.combine(sticker)
        hasher.combine(message)
        hasher.combine(type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
