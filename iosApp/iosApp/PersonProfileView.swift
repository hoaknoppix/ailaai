//
//  PersonProfileView.swift
//  AiLaAi
//
//  Created by Hoa Tran on 6/2/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat
import PhotosUI

struct PersonProfileView: View, GetPersonProfileSuccessProtocol, CreateGroupsSuccessProtocol, CreateMemberProtocol, GetGroupsSuccessProtocol, GetMessagesSuccessProtocol {
    func execute(messages: [MessageDTO]) {
        globalVariables.messages = Array(Set(messages))
        globalVariables.uiMessages = messages.map {
            SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
        }
            .sorted {
            $0.createdAt < $1.createdAt
        }
        print("Messages are loaded!!!")
    }
    
    func execute(groups: [Group]) {
        globalVariables.groups = groups
        groups.forEach { group in
            group.members.forEach { m in
                let person = m.person
                let member = m.member
                if (globalVariables.personByGroup[group.group.id] == nil) {
                    globalVariables.personByGroup[group.group.id] = [:]
                }
                globalVariables.personByGroup[group.group.id]![member.id] = person
                
                if (globalVariables.memberByPerson[group.group.id] == nil) {
                    globalVariables.memberByPerson[group.group.id] = [:]
                }
                globalVariables.memberByPerson[group.group.id]![person.id] = member
                if (!globalVariables.userFriends.contains(m.person) && (m.person.id != globalVariables.userInfo?.id)) {
                    globalVariables.userFriends.insert(m.person)
                }
            }
        }
        globalVariables.group = groups.first(where: { g in
            g.group.id == globalVariables.newGroupId
        })
        globalVariables.messages = []
        globalVariables.uiMessages = []
        viewPersonProfile = false
        viewMembers = false
        viewMessages = true
    }
    
    func execute() {
        SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
    }
    
    func onCreateNewGroupSuccess(groupId: String) {
        globalVariables.newGroupId = groupId
        if let personProfile = globalVariables.personProfile {
            SwiftAPI.createMember(token: globalVariables.token, memberId: personProfile.person.id, groupId: groupId, onSuccess: self)
        }
    }
    
    func onUpdateNameNewGroupSuccess(groupId: String, groupName: String) {
        //do nothing
    }
    
    func execute(personProfile: PersonProfile) {
        globalVariables.personProfile = personProfile
    }
    
    @Binding var viewPersonProfile: Bool
    @Binding var viewMembers: Bool
    @Binding var viewMessages: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    @State private var avatarImage: Image?
    @State private var avatarItem: PhotosPickerItem?
    
    var body: some View {
        
        VStack() {
                CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: globalVariables.personProfile?.person.photo ?? ""))) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(.circle)
                        .padding(4)
                        .background {
                            Circle()
                                .foregroundStyle(.background)
                        }
                } placeholder: {
                    Rectangle().fill(Color.gray)
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 15) {
//                    Button {
//                    } label: {
                        Text(globalVariables.personProfile?.person.name ?? "").font(.title).bold()
//                    }
                    
                }.padding([.leading, .trailing], 27.5)
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        //http(.)+
                        Text(.init(globalVariables.personProfile?.profile.about ?? "")).font(.subheadline).bold()
                            .textSelection(.enabled)
                    }.padding([.leading, .trailing], 27.5).textSelection(.enabled)
                    Spacer()
                    Spacer()
                }.textSelection(.enabled)
                Button(action: {
                    print("Send a message")
                    if let group = globalVariables.groups.first(where: { g in
                        return g.group.name == nil && g.members.count == 2 && g.members.contains(where: { m in
                            m.person.id == globalVariables.personProfile?.person.id || m.person.id == globalVariables.userProfile?.id
                        })
                    }) {
                        globalVariables.group = group
                        globalVariables.messages = []
                        globalVariables.uiMessages = []
                        SwiftAPI.getMesssages(token: globalVariables.token, groupId: group.group.id, onSuccess: self)
                        viewPersonProfile = false
                        viewMembers = false
                        viewMessages = true
                    } else {
                        SwiftAPI.createGroup(token: globalVariables.token, groupName: nil, onSuccess: self)
                    }
                }) {
                    Text("Send a message")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black)
                        .cornerRadius(15.0)
                }.padding(.top, 50)
                Button(action: {
                    viewPersonProfile = false
                    if (globalVariables.isFromMemberScreen) {
                        viewMembers = true
                    }
                }) {
                    Text("Go back")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black)
                        .cornerRadius(15.0)
                }
                
                Spacer()
            }
    }
}
