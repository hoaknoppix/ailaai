//
//  MessageView.swift
//  iosApp
//
//  Created by Hoa Tran on 11/8/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat
import AlertToast

extension MessageView: SendMediaErrorProtocol {
    func handleError() {
        globalVariables.uiMessages.removeLast()
    }
}


struct MessageView: View, SendMessageSuccessProtocol, GetMessagesSuccessProtocol, SendMediaSuccessProtocol, LeaveGroupProtocol {
    func leave() {
        withAnimation {
            if globalVariables.userInfo != nil {
                if let groupId = globalVariables.group?.group.id {
                    globalVariables.memberByPerson[groupId]![globalVariables.userInfo!.id] = nil
                }
                viewMessages = false
            }
        }
    }
    
    func execute(messages: [MessageDTO]) {
        print("Yeah.....")
        var tmp = messages
        tmp.reverse()
        if (!tmp.isEmpty) {
            tmp.removeLast()
        }
        for message in messages {
            if !globalVariables.messages.contains(where: { m in
                m.id == message.id
            }) {
                globalVariables.messages.insert(message, at: 0)
            }
        }
        let newMessages = tmp.map {
            SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
        }
            .sorted {
            $0.createdAt < $1.createdAt
        }
        for newMessage in newMessages {
            if !globalVariables.uiMessages.contains(where: { m in
                m.id == newMessage.id
            }) {
                globalVariables.uiMessages.insert(newMessage, at: 0)
            }
        }
    }
    
    @Binding var viewMessages: Bool
    @Binding var viewMembers: Bool
    @State private var showToastPleaseJoinToSendMessage = false
    @EnvironmentObject var globalVariables: GlobalVariables
    @State private var showingAlert = false
    @Environment(\.scenePhase) var scenePhase
    
    func execute() {
                
//        globalVariables.uiMessages.last!.
        if var tmp = globalVariables.uiMessages.last {
            tmp.status = .sent
            globalVariables.uiMessages.removeLast()
            globalVariables.uiMessages.append(tmp)
        }
    }
    

    var body: some View 
    {
//        NavigationView {
//            VStack {
                //            Image(systemName: "star.fill")
                HStack {
                    Button {
                        withAnimation {
                            viewMessages = false
                            viewMembers = false
                            globalVariables.isFromMemberScreen = false
                            AppState.shared.isNotified = false
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                        //                        .resizable()
                            .frame(width: 20, height: 20)
                    }
                    //                .frame(alignment: .leading)
                    //            VStack {
                    CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: globalVariables.group?.group.photo ?? globalVariables.group?.members.filter({ m in
                        return m.person.id != globalVariables.userInfo?.id}).first?.person.photo ?? ""))) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color.gray)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    Text(globalVariables.group?.group.name ?? globalVariables.group?.members.filter({ m in
                        return m.person.id != globalVariables.userInfo?.id}).first?.person.name ?? "")
                    .font(.system(size:20, weight: .bold, design: .default))
                    .onTapGesture {
                        withAnimation {
                            viewMessages = false
                            viewMembers = true
                            globalVariables.isFromMemberScreen = true
                            AppState.shared.isNotified = false
                        }
                    }
                    //            }
                    if let tmp = globalVariables.memberByPerson[globalVariables.group!.group.id] {
                        if (tmp[globalVariables.userInfo!.id] != nil) {
                            Button {
                                showingAlert = true
                                //                let memberId = globalVariables.memberByPerson[globalVariables.group!.group.id]![globalVariables.userInfo!.id]!
                                //                SwiftAPI.leaveGroup(token: globalVariables.token, memberId: memberId, onSuccess: self)
                                //                UserDefaults.standard.set("Guru", forKey: "notificationGroupId")
                                //                print("Settt")
                            } label: {
                                Text("Leave")
                            }
                        }
                    }
                }
                .toast(isPresenting: $showToastPleaseJoinToSendMessage, alert: {
                    AlertToast(displayMode: .hud, type: .regular, title: NSLocalizedString("Only member can send a message.", comment: ""))
                })
                .alert(NSLocalizedString("Do you want to leave?", comment: ""), isPresented: $showingAlert) {
                    Button("OK", role: .none) {
                        let memberId = globalVariables.memberByPerson[globalVariables.group!.group.id]![globalVariables.userInfo!.id]!.id
                        SwiftAPI.leaveGroup(token: globalVariables.token, memberId: memberId, onSuccess: self)
                        showingAlert = false
                    }
                    Button("Cancel", role: .cancel) {
                        showingAlert = false
                    }
                }
                
            ChatView(messages: globalVariables.uiMessages) { draftMessage in
                //sticker, photos
//                if globalVariables.uiMessages.contains(where: { m in
//                    m.id == draftMessage.id
//                }) {
//                    print("I have no idea what happens")
////                    return
//                }
                if (globalVariables.memberByPerson[globalVariables.group!.group.id]![globalVariables.userInfo!.id] == nil) {
                    showToastPleaseJoinToSendMessage = true
                    return
                }
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
                
            }
            .enableLoadMore(pageSize: 20) { Message in
                if let time = globalVariables.uiMessages.first?.createdAt {
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
                    let timeString = dateFormatter.string(from:time)
                    SwiftAPI.getMesssages(token: globalVariables.token, groupId: globalVariables.group!.group.id, before: timeString, onSuccess: self)
                }
            }
            .onAppear {
                globalVariables.isAtChatView = true
            }
            .onDisappear {
                globalVariables.isAtChatView = false
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    globalVariables.isAtChatView = true
                } else if newPhase == .inactive {
                    globalVariables.isAtChatView = false
                } else if newPhase == .background {
                    globalVariables.isAtChatView = false
                }
            }
//            .onChange(of: scenePhase) { oldPhase, newPhase in
//                if newPhase == .active {
//                    globalVariables.isAtChatView = true
//                } else if newPhase == .inactive {
//                    globalVariables.isAtChatView = false
//                } else if newPhase == .background {
//                    globalVariables.isAtChatView = false
//                }
//            }
//            }
//        }.onAppear(perform: fetchMessage)
//            .onDisappear(perform: cleanMessages)
    }
    
}


struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(viewMessages: .constant(true), viewMembers: .constant(false))
    }
}
