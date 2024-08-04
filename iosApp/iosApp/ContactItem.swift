//
//  ContactItem.swift
//  iosApp
//
//  Created by Hoa Tran on 11/6/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat
import LoadingView

struct ContactItem: View, GetMessagesSuccessProtocol, JoinGroupProtocol, DeleteJoinRequestSuccessProtocol, GetJoinRequestSuccessProtocol {
    
    func execute(joinRequests: [GetJoinRequest]) {
        globalVariables.joinRequests = joinRequests
    }
    
    func completeDeleteJoinRequest(id: String) {
        if let index = globalVariables.joinRequests.firstIndex(where: { j in
            j.joinRequest.id == id
        }) {
            globalVariables.joinRequests.remove(at: index)
        }
    }
    
    func join(joinRequestResponse: JoinRequestResponse) {
        SwiftAPI.getJoinRequests(token: globalVariables.token, onSuccess: self)
    }
    
    func execute(messages: [MessageDTO]) {
        globalVariables.messages = Array(Set(messages))
        globalVariables.uiMessages = globalVariables.messages.map {
            SwiftAPI.getUIMessage(message: $0, globalVariables: globalVariables)
        }
        .sorted {
            $0.createdAt < $1.createdAt
        }
        isLoading = false
        withAnimation {
            viewMessages = true
        }
        print("Messages are loaded!!!")
    }
    
    @Binding var viewMessages: Bool
    @State private var isLoading: Bool = false
    var group: Group
    @EnvironmentObject var globalVariables: GlobalVariables
    
    var body: some View {
        HStack{
            Spacer()

//            AvatarView(
//                url: URL(string: "https://placeimg.com/640/480/sepia"),
//                avatarSize: 32
//            )
//            AvatarView(url: URL(string: group.group.photo ?? ""), avatarSize: 60)
            CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: group.group.photo ?? (group.members.first(where: { m in
                return m.person.id != globalVariables.userInfo?.id
            }) ?? group.members[0]).person.photo ?? ""))) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
//            CachedAsyncImage(url: group.group.photo ?? "", urlCache: .imageCache) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//            } placeholder: {
//                Rectangle().fill(Color.gray)
//            }
//            .viewSize(60)
//            .clipShape(Circle())
//            Image(systemName: "star.fill")
            //userImage)
//                .resizable()
//                .background( Color("color_bg_inverted").opacity(0.05))
//                .frame(width: 60, height: 60)
//                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6){
                HStack{
                    Text(group.group.name ?? group.members.filter({ MemberElement in
                        return MemberElement.person.id != globalVariables.userInfo?.id
                    }).first?.person.name ?? "")
                        .fontWeight(.semibold)
                        .padding(.top, 3)
//                    Spacer()
//                    Image(systemName: "phone")
//                        .foregroundColor(Color("color_primary"))
//                        .padding(.horizontal)
//                    Image(systemName: "bubble.right")
//                        .foregroundColor(Color("color_primary"))
                }
                HStack{
                    Text(group.group.description ?? group.latestMessage?.text ?? "")
//                        .foregroundColor(Color("color_bg_inverted").opacity(0.5))
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                }
                
                Divider()
                    .padding(.top, 8)
            }
            .padding(.horizontal, 10)
            if let request = globalVariables.joinRequests.first(where: { j in
                j.joinRequest.group == group.group.id
            }) {
                Button(action: {
                    SwiftAPI.deleteJoinRequest(token: globalVariables.token, joinRequest: request.joinRequest.id, onSuccess: self)
                }) {
                    Text(NSLocalizedString("Withdraw", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 110, height: 40)
                        .background(Color.black)
                        .cornerRadius(15.0)
                    //                    .shadow(radius: 10.0, x: 20, y: 10)
                }
            }
            else if let peopleInGoup = globalVariables.memberByPerson[group.group.id] {
                if (globalVariables.userInfo != nil && peopleInGoup[globalVariables.userInfo!.id] == nil) {
                    Button(action: {
                        //call join api
                        SwiftAPI.joinGroup(token: globalVariables.token, groupId: group.group.id, message: "", onSuccess: self)
                    }) {
                        Text(NSLocalizedString("Join", comment: ""))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 110, height: 40)
                            .background(Color.black)
                            .cornerRadius(15.0)
                        //                    .shadow(radius: 10.0, x: 20, y: 10)
                    }
                }
            }
        }.onTapGesture {
            globalVariables.group = group
            isLoading = true
            globalVariables.uiMessages.removeAll()
            SwiftAPI.getMesssages(token: globalVariables.token, groupId: group.group.id, onSuccess: self)
        }.dotsIndicator(when: $isLoading)
    }
}
