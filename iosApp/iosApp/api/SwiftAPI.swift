//
//  SwiftAPI.swift
//  iosApp
//
//  Created by Hoa Tran on 11/21/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Alamofire
//import shared
import ExyteChat
import AVFAudio
import AVFoundation


struct TokenResponse : Codable {
    var token: String
}

struct TransferResponse: Codable {
    var code: String
}

protocol CreateGroupsSuccessProtocol {
    func onCreateNewGroupSuccess(groupId: String)
    func onUpdateNameNewGroupSuccess(groupId: String, groupName: String)
}


protocol SignInSuccessProtocol {
    func execute(token: String)
}

protocol SignInFailureProtocol {
    func execute(error: String)
}

protocol TransferSuccessProtocol {
    func execute(code: String)
}

protocol RemoveAccountSuccessProtocol {
    func doAfterRemove()
}



protocol SignUpSuccessProtocol {
    func execute(token: String)
}

protocol GetGroupsSuccessProtocol {
    func execute(groups: [Group])
}

protocol GetLocalGroupsSuccessProtocol {
    func execute(localgroups: [Group])
}

protocol GetMessagesSuccessProtocol {
    func execute(messages: [MessageDTO])
}

protocol GetMessagesInRangeSuccessProtocol {
    func execute(messagesInRange: [MessageDTO])
}

protocol SendMessageSuccessProtocol {
    func execute()
}

protocol DeleteJoinRequestSuccessProtocol {
    func completeDeleteJoinRequest(id: String)
}

protocol UpdateProfileSuccessProtocol {
    func execute(userInfo: UserInfo)
}

protocol GetProfileSuccessProtocol {
    func execute(userProfile: UserProfile)
}

protocol GetJoinRequestSuccessProtocol {
    func execute(joinRequests: [GetJoinRequest])
}


protocol GetPersonProfileSuccessProtocol {
    func execute(personProfile: PersonProfile)
}

protocol SendMediaSuccessProtocol {
    func execute()
}

protocol UpdatePhotoSuccessProtocol {
    func execute()
}

protocol ReportSuccessProtocol {
    func doAfterReport()
}

protocol SendMediaErrorProtocol {
    func handleError()
}

protocol GetUserInfoSuccessProtocol {
    func execute(userInfo: UserInfo)
}

protocol LeaveGroupProtocol {
    func leave()
}

protocol JoinGroupProtocol {
    func join(joinRequestResponse: JoinRequestResponse)
}

protocol CreateMemberProtocol {
    func execute()
}


struct SwiftAPI {
    
    static var endPoint = "https://api.ailaai.app"
    
    static func getImageUrl(path: String) -> String {
        return "\(endPoint)\(path)"
    }
    
    static func createMember(token: String, memberId: String, groupId: String, onSuccess: CreateMemberProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "from" : memberId,
            "to": groupId
        ]
        let url = "\(endPoint)/members"
        print(url)
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(_):
                onSuccess.execute()
            case .failure(let error):
                print("Cannot create member\(error)")
            }
        })
    }
        
    static func deleteJoinRequest(token: String, joinRequest:String, onSuccess: DeleteJoinRequestSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let url = "\(endPoint)/join-requests/\(joinRequest)/delete"
        print(url)
        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseData(emptyResponseCodes: [200], completionHandler: { response in
            print("response\(response)")
            switch response.result {
            case .success(_):
                onSuccess.completeDeleteJoinRequest(id: joinRequest)
            case .failure(let error):
                print("Cannot delete join request\(error)")
            }
        })
    }
    static func joinGroup(token: String, groupId:String, message: String, onSuccess: JoinGroupProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "group": groupId,
            "message": message
        ]
        let url = "\(endPoint)/join-requests"
        print(url)
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: JoinRequestResponse.self) { response in
            switch response.result {
            case .success(let joinRequestResponse):
                onSuccess.join(joinRequestResponse: joinRequestResponse)
            case .failure(let error):
                print("Cannot join group\(error)")
            }
        }
    }
    
    static func reportGroup(token: String, groupId: String, onSuccess: ReportSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "entity" : "group/\(groupId)",
            "type": "Other"
        ]
        let url = "\(endPoint)/report"
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData(emptyResponseCodes: [204], completionHandler: { response in
            print("response:\(response)")
            switch response.result {
            case .success(_):
                onSuccess.doAfterReport()
            case .failure(let error):
                print("Cannot report group\(error)")
            }
        })
    }
    
    static func leaveGroup(token: String, memberId: String, onSuccess: LeaveGroupProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let url = "\(endPoint)/members/\(memberId)/delete"
        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(_):
                onSuccess.leave()
            case .failure(let error):
                print("Cannot leave group\(error)")
            }
        })
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
                print("Cannot get userInfo\(error)")
            }
        }
    }
    
    static func updateProfile(token: String, about: String, onSuccess: GetProfileSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "about" : about
        ]
        AF.request("\(endPoint)/me/profile", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UserProfile.self) { response in
            switch response.result {
            case .success(let userProfile):
                onSuccess.execute(userProfile: userProfile)
            case .failure(let error):
                print("Cannot get userProfile\(error)")
            }
        }
    }
    
    static func getJoinRequests(token: String, onSuccess: GetJoinRequestSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/me/join-requests", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: [GetJoinRequest].self) { response in
            switch response.result {
            case .success(let joinRequests):
                onSuccess.execute(joinRequests: joinRequests)
            case .failure(let error):
                print("Cannot get join-requests \(error)")
            }
        }
    }
    
    static func getUserProfile(token: String, onSuccess: GetProfileSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/me/profile", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UserProfile.self) { response in
            switch response.result {
            case .success(let userProfile):
                onSuccess.execute(userProfile: userProfile)
            case .failure(let error):
                print("Cannot get user profile \(error)")
            }
        }
    }
    
    static func getPersonProfile(token: String, personId: String, onSuccess: GetPersonProfileSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/people/\(personId)/profile", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: PersonProfile.self) { response in
            switch response.result {
            case .success(let personProfile):
                onSuccess.execute(personProfile: personProfile)
            case .failure(let error):
                print("Cannot get person profile \(error)")
            }
        }
    }

    
    static func updateProfilePhoto(token: String, photo: Data) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.upload(multipartFormData: { (multiFormData) in
            multiFormData.append(photo, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
        }, to: "\(endPoint)/me/profile/photo", headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    static func updatePhoto(token: String, photo: Data, onSuccess: UpdatePhotoSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.upload(multipartFormData: { (multiFormData) in
            multiFormData.append(photo, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
        }, to: "\(endPoint)/me/photo", headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(_):
                onSuccess.execute()
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    static func signUp(onSuccess: SignUpSuccessProtocol) {
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
    
    static func signIn(code: String, onSuccess: SignInSuccessProtocol, onFailure: SignInFailureProtocol) {
        let parameters: [String: Any] = [
            "code" : code //"l0HbWk3o2TJmlQV0"
        ]
        AF.request("\(endPoint)/sign/in", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: TokenResponse.self) { response in
            switch response.result {
            case .success(let tokenData):
                onSuccess.execute(token: tokenData.token)
            case .failure(let error):
                onFailure.execute(error: error.localizedDescription)
            }
        }
    }
    
    
    
    static func transferCode(token: String, onSuccess: TransferSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/me/transfer", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: TransferResponse.self) { response in
            switch response.result {
            case .success(let transferData):
                onSuccess.execute(code: transferData.code)
            case .failure(let error):
                print("Cannot sign in\(error)")
            }
        }
    }
    
    static func removeAccount(token: String, onSuccess: RemoveAccountSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/me/delete", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData(completionHandler: { response in
            switch response.result {
            case .success(_):
                onSuccess.doAfterRemove()
            case .failure(let error):
                print("Cannot remove:\(error)")
            }
        })
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
        print(token)
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        AF.request("\(endPoint)/groups", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: [Group].self) { response in
            switch response.result {
            case .success(let groups):
                onSuccess.execute(groups: groups)
            case .failure(let error):
                print("Cannot get groups\(error)")
            }
        }
    }
    
    static func getLocalGroups(token: String, geoString: String, isPublic: Bool, limit: Int, offset: Int, onSuccess: GetLocalGroupsSuccessProtocol) {
        print(token)
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        //URLEncoding(destination: .queryString)
        AF.request("\(endPoint)/groups/explore?geo=\(geoString)&public=\(isPublic)&limit=\(limit)&offset=\(offset)", method: .get, headers: headers)
            .responseDecodable(of: [Group].self) { response in
            switch response.result {
            case .success(let groups):
                onSuccess.execute(localgroups: groups)
            case .failure(let error):
                print("Cannot get groups\(error)")
            }
        }
    }
    
    /*
     {
         "id": "30235289",
         "createdAt": "2024-05-26T16:56:28.602Z",
         "seen": "2024-05-26T16:56:28.602Z"
     }
     */
    static func createGroup(token: String, groupName: String?, onSuccess: CreateGroupsSuccessProtocol) {
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "people" : []
        ]
        AF.request("\(endPoint)/groups", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: CreateGroupResponse.self) { response in
            switch response.result {
            case .success(let response):
                if (groupName != nil) {
                    updateGroup(token: token, groupId: response.id, groupName: groupName!, onSuccess: onSuccess)
                }
                onSuccess.onCreateNewGroupSuccess(groupId: response.id)
            case .failure(let error):
                print("Cannot create group \(error)")
            }
        }
    }
    
    static func updateGroup(token: String, groupId: String, groupName: String, onSuccess: CreateGroupsSuccessProtocol) {
        print(groupName)
        let headers: HTTPHeaders = [.authorization(bearerToken: token)]
        let parameters: [String: Any] = [
            "name" : groupName
        ]
        AF.request("\(endPoint)/groups/\(groupId)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: UpdateNameGroupResponse.self) { response in
            switch response.result {
            case .success(let response):
                onSuccess.onUpdateNameNewGroupSuccess(groupId: response.id, groupName: groupName)
            case .failure(let error):
                print("Cannot create group \(error)")
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
            case .success(_):
                onSuccess.execute()
            case .failure(_):
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
            case .success(_):
                onSuccess.execute()
            case .failure(_):
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
            case .success(_):
                onSuccess.execute()
            case .failure(_):
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
        let belongsToThisUser = globalVariables.personByGroup[message.group]?[message.member]?.id == globalVariables.userInfo?.id
        let photo = globalVariables.personByGroup[message.group]?[message.member]?.photo ?? ""
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
                    let tmp = Attachment(id: UUID().uuidString, thumbnail: getImageURL(image: photo)!, full: getImageURL(image: photo)!, type: AttachmentType.image)
                    attachments.append(tmp)
                }
            } else if attachment.type == "sticker" {
                let tmp = Attachment(id: UUID().uuidString, thumbnail: getImageURL(image: attachment.photo!)!, full: getImageURL(image: attachment.photo!)!, type: AttachmentType.image)
                attachments.append(tmp)
            } else if attachment.type == "audio" {
                recordingUrl = getImageUrl(path: attachment.audio!)
            } else if attachment.type == "videos" {
                attachment.videos!.forEach { video in
                    do {
                        let url = getImageURL(image: video)!
                        if let q = NSData(contentsOf: url) {
                            let documentsPath = NSTemporaryDirectory()
                            
                            let fileName = UUID().uuidString;
                            
                            let filePath="\(documentsPath)/\(fileName).mp4";
                            try q.write(toFile: filePath)
                            let tmp = Attachment(id: UUID().uuidString, thumbnail: URL(fileURLWithPath: filePath), full: URL(fileURLWithPath: filePath), type: AttachmentType.video)
                            
                            //                        var tmp = Attachment(id: UUID().uuidString, thumbnail: getImageURL(image: video)!, full: getImageURL(image: video)!, type: AttachmentType.video)
                            attachments.append(tmp)
                        }
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
        print("I have a ui message\(message)")
        return message
    }
    
    static func getImageURL(image: String) -> URL? {
        let imageUrl = "https://api.ailaai.app\(image)"
        return URL(string: imageUrl)
    }
}
