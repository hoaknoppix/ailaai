//
//  SwiftAPI.swift
//  iosApp
//
//  Created by Hoa Tran on 11/21/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Alamofire
import shared
import ExyteChat
import AVFAudio
import AVFoundation


struct TokenResponse : Codable {
    var token: String
}



protocol SignInSuccessProtocol {
    func execute(token: String)
}

protocol SignUpSuccessProtocol {
    func execute(token: String)
}

protocol GetGroupsSuccessProtocol {
    func execute(groups: [Group])
}

protocol GetMessagesSuccessProtocol {
    func execute(messages: [MessageDTO])
}

protocol SendMessageSuccessProtocol {
    func execute()
}

protocol UpdateProfileSuccessProtocol {
    func execute(userInfo: UserInfo)
}

protocol SendMediaSuccessProtocol {
    func execute()
}

protocol SendMediaErrorProtocol {
    func handleError()
}

protocol GetUserInfoSuccessProtocol {
    func execute(userInfo: UserInfo)
}


struct SwiftAPI {
    
    static var endPoint = "https://api.ailaai.app"
    
    static func getImageUrl(path: String) -> String {
        return "\(endPoint)\(path)"
    }
    
    static func updateProfile(token: String, name: String, onSuccess: UpdateProfileSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "name" : name
        ]
        AF.request("\(endPoint)/me", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UserInfo.self) { response in
            switch response.result {
            case .success(let userInfo):
                onSuccess.execute(userInfo: userInfo)
            case .failure(let error):
                print("Cannot get userINfo\(error)")
            }
        }
    }
    
    static func signUp(code: String, onSuccess: SignUpSuccessProtocol) {
        let parameters: [String : Any] = [:]
        AF.request("\(endPoint)/sign/up", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: TokenResponse.self) { response in
            switch response.result {
            case .success(let tokenData):
                onSuccess.execute(token: tokenData.token)
            case .failure(let error):
                print("Cannot sign up\(error)")
            }
        }
    }
    
    static func signIn(code: String, onSuccess: SignInSuccessProtocol) {
        let parameters: [String: Any] = [
            "code" : code //"l0HbWk3o2TJmlQV0"
        ]
        AF.request("\(endPoint)/sign/in", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: TokenResponse.self) { response in
            switch response.result {
            case .success(let tokenData):
                onSuccess.execute(token: tokenData.token)
            case .failure(let error):
                print("Cannot sign in\(error)")
            }
        }
    }
    
    static func getUserInfo(token: String, onSuccess: GetUserInfoSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UserInfo.self) { response in
            switch response.result {
            case .success(let userInfo):
                onSuccess.execute(userInfo: userInfo)
            case .failure(let error):
                print("Cannot get userINfo\(error)")
            }
        }
    }
    
    static func getGroups(token: String, onSuccess: GetGroupsSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/groups", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: [Group].self) { response in
            switch response.result {
            case .success(let groups):
                onSuccess.execute(groups: groups)
            case .failure(let error):
                print("Cannot get groups\(error)")
            }
        }
    }
    
    static func getMesssages(token: String, groupId: String, before: String? = nil, limit: String? = nil, onSuccess: GetMessagesSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        var url = "\(endPoint)/groups/\(groupId)/messages"
        if (before != nil) {
            url = "\(url)?before=\(before!)"
        }
        if (limit != nil) {
            url = "\(url)?limit=\(limit!)"
        }
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: [MessageDTO].self) { response in
            switch response.result {
            case .success(let messages):
                onSuccess.execute(messages: messages)
            case .failure(let error):
                print("Cannot get messages: \(error)")
            }
        }
    }
    
    static func sendMedia(token: String, groupId: String, text: String, photos: [Data], onSuccess: SendMediaSuccessProtocol, onError: SendMediaErrorProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.upload(multipartFormData: { (multiFormData) in
            if (text.data(using: .utf8) != nil) {
                multiFormData.append(text.data(using: .utf8)!, withName: "message.text")
            }
            for index in 0...photos.count-1 {
                multiFormData.append(photos[index], withName: "photo[\(index)]", fileName: "photo.jpg", mimeType: "image/jpeg")
            }
        }, to: "\(endPoint)/groups/\(groupId)/photos", headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(let message):
                onSuccess.execute()
            case .failure(let error):
                onError.handleError()
            }
        })
        
    }
    
    
    static func sendAudio(token: String, groupId: String, text: String, audio: Data, onSuccess: SendMediaSuccessProtocol, onError: SendMediaErrorProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.upload(multipartFormData: { (multiFormData) in
            if (text.data(using: .utf8) != nil) {
                multiFormData.append(text.data(using: .utf8)!, withName: "message.text")
            }
            multiFormData.append(audio, withName: "audio", fileName: "audio.aac", mimeType: "audio/aac")
        }, to: "\(endPoint)/groups/\(groupId)/audio", headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(let message):
                onSuccess.execute()
            case .failure(let error):
                onError.handleError()
            }
        })
        
    }
    
    
    static func sendVideo(token: String, groupId: String, text: String, photos: [Data], onSuccess: SendMediaSuccessProtocol, onError: SendMediaErrorProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.upload(multipartFormData: { (multiFormData) in
            if (text.data(using: .utf8) != nil) {
                multiFormData.append(text.data(using: .utf8)!, withName: "message.text")
            }
            for index in 0...photos.count-1 {
                multiFormData.append(photos[index], withName: "photo[\(index)]", fileName: "video.mp4", mimeType: "video/mp4")
            }
        }, to: "\(endPoint)/groups/\(groupId)/videos", headers: headers).responseData(completionHandler: {response in
            switch response.result {
            case .success(let message):
                onSuccess.execute()
            case .failure(let error):
                onError.handleError()
            }
        })
        
    }
    
    static func updateDeviceToken(token: String, deviceToken: String) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "type" : "Apns",
            "token": deviceToken
        ]
        AF.request("\(endPoint)/me/device", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData(completionHandler: { tmp in
            print("Update device token successfully!!!")
        })
    }
    
    static func sendMessage(token: String, groupId: String, text: String, onSuccess: SendMessageSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "text" : text
        ]
        AF.request("\(endPoint)/groups/\(groupId)/messages", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData(completionHandler: { tmp in
            onSuccess.execute()
        })
    }
    
    static func getCurrentUser(globalVariables: GlobalVariables) -> User {
        return User(id: globalVariables.userInfo!.id, name: globalVariables.userInfo!.name, avatarURL: getImageURL(image: globalVariables.userInfo!.photo ?? ""), isCurrentUser: true)
    }
    
    static func getUIMessage(message: MessageDTO, globalVariables: GlobalVariables)  -> Message {
        print("I have a message\(message)")
        var belongsToThisUser = globalVariables.personByGroup[message.group]?[message.member]?.id == globalVariables.userInfo?.id
        var photo = globalVariables.personByGroup[message.group]?[message.member]?.photo ?? ""
        let user = User(id: message.member, name: message.member, avatarURL: getImageURL(image: photo), isCurrentUser: belongsToThisUser)
        var attachments: [Attachment] = []
        var recordingUrl: String = ""
//        message.attachment
        if (message.attachment != nil) {
            let data = message.attachment!.data(using: .utf8)
            let decoder = JSONDecoder()
            let attachment = try! decoder.decode(AttachmentDTO.self, from: data!)
            print(attachment)
            if attachment.type == "photos" {
                attachment.photos!.forEach { photo in
                    var tmp = Attachment(id: UUID().uuidString, thumbnail: getImageURL(image: photo)!, full: getImageURL(image: photo)!, type: AttachmentType.image)
                    attachments.append(tmp)
                }
            } else if attachment.type == "sticker" {
                var tmp = Attachment(id: UUID().uuidString, thumbnail: getImageURL(image: attachment.photo!)!, full: getImageURL(image: attachment.photo!)!, type: AttachmentType.image)
                attachments.append(tmp)
            } else if attachment.type == "audio" {
                recordingUrl = getImageUrl(path: attachment.audio!)
            } else if attachment.type == "videos" {
                attachment.videos!.forEach { video in
                    do {
                        var url = getImageURL(image: video)!
                        var q = NSData(contentsOf: url)
                        let documentsPath = NSTemporaryDirectory()
                        
                        let fileName = UUID().uuidString;
                        
                        let filePath="\(documentsPath)/\(fileName).mp4";
                        try q!.write(toFile: filePath)
                        print("asdfasdfvideo\(url)")
                        var tmp = Attachment(id: UUID().uuidString, thumbnail: URL(fileURLWithPath: filePath), full: URL(fileURLWithPath: filePath), type: AttachmentType.video)

//                        var tmp = Attachment(id: UUID().uuidString, thumbnail: getImageURL(image: video)!, full: getImageURL(image: video)!, type: AttachmentType.video)
                        attachments.append(tmp)
                    } catch {
                        
                    }
                }
            }
        }
        let isoDate = message.createdAt

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        let date = dateFormatter.date(from:isoDate)!
        var message = Message(id: message.id, user: user, createdAt: date, text: message.text ?? "", attachments: attachments)
        if (recordingUrl != "") {
            let url = URL(string: recordingUrl)!
            var recording = Recording()
            recording.url = url
            message.recording = recording
        }
        message.status = .sent
        //attachements & stickers....
        return message
    }
    
    static func getImageURL(image: String) -> URL? {
        let imageUrl = "https://api.ailaai.app\(image)"
        return URL(string: imageUrl)
    }
}
