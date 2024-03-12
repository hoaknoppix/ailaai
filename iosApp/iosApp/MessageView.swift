//
//  MessageView.swift
//  iosApp
//
//  Created by Hoa Tran on 11/8/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat

extension MessageView: SendMediaErrorProtocol {
    func handleError() {
        globalVariables.uiMessages.removeLast()
    }
}

struct MessageView: View, SendMessageSuccessProtocol, GetMessagesSuccessProtocol, SendMediaSuccessProtocol {
    func execute(messages: [MessageDTO]) {
        var tmp = messages
        tmp.reverse()
        tmp.removeLast()
        globalVariables.messages.append(contentsOf: messages)
        var newMessages = tmp.map {
            SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
        }
            .sorted {
            $0.createdAt < $1.createdAt
        }
        globalVariables.uiMessages.insert(contentsOf: newMessages, at: 0)
    }
    
    @Binding var viewMessages: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    
    func execute() {
                
//        globalVariables.uiMessages.last!.
        var tmp = globalVariables.uiMessages.last!
        tmp.status = .sent
        globalVariables.uiMessages.removeLast()
        globalVariables.uiMessages.append(tmp)
    }
    

    var body: some View {
        //            Image(systemName: "star.fill")
        HStack {
            Button {
                viewMessages = false
                AppState.shared.isNotified = false
//                UserDefaults.standard.set("Guru", forKey: "notificationGroupId")
//                print("Settt")
                } label: {
                    Image(systemName: "chevron.backward")
//                        .resizable()
                        .frame(width: 20, height: 20)
                }
//                .frame(alignment: .leading)
//            VStack {
                CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: globalVariables.group?.group.photo ?? globalVariables.group?.members[0].person.photo ?? ""))) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                Text(globalVariables.group?.group.name ?? globalVariables.group?.members[0].person.name ?? "")
                    .font(.system(size:20, weight: .bold, design: .default))
//            }


        }
                
        ChatView(messages: globalVariables.uiMessages) { draftMessage in
            //sticker, photos
            if (draftMessage.medias.isEmpty && draftMessage.recording == nil) {
                SwiftAPI.sendMessage(token: globalVariables.token, groupId: globalVariables.group!.group.id, text: draftMessage.text, onSuccess: self)
                Task {
                    let message = await Message.makeMessage(id: UUID.init().uuidString, user: SwiftAPI.getCurrentUser(globalVariables: globalVariables), status: .sending, draft: draftMessage)
                    globalVariables.uiMessages.append(message)
                }
            } else {
                Task {
                    var photos: [Data] = []
                    var videos: [Data] = []
                    for media in draftMessage.medias {
                        if (media.type == .image) {
                            photos.append(await media.getData()!)
                        } else if (media.type == .video) {
                            videos.append(await media.getData()!)
                        }
                    }
                    if !photos.isEmpty {
                        SwiftAPI.sendMedia(token: globalVariables.token, groupId: globalVariables.group!.group.id, text: draftMessage.text, photos: photos, onSuccess: self, onError: self)
                    }
                    else if draftMessage.recording != nil {
                        let audio: Data = try Data(contentsOf: draftMessage.recording!.url!)
                            SwiftAPI.sendAudio(token: globalVariables.token, groupId: globalVariables.group!.group.id, text: draftMessage.text, audio: audio, onSuccess: self, onError: self)
                    }
                    if !videos.isEmpty {
                        SwiftAPI.sendVideo(token: globalVariables.token, groupId: globalVariables.group!.group.id, text: draftMessage.text, photos: videos, onSuccess: self, onError: self)
                    }
                    let message = await Message.makeMessage(id: UUID.init().uuidString, user: SwiftAPI.getCurrentUser(globalVariables: globalVariables), status: .sending, draft: draftMessage)
                    globalVariables.uiMessages.append(message)
                }
            }
            
        }.enableLoadMore { Message in
            let time = globalVariables.messages.last!.createdAt
            SwiftAPI.getMesssages(token: globalVariables.token, groupId: globalVariables.group!.group.id, before: time, onSuccess: self)
        }

    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(viewMessages: .constant(true))
    }
}
