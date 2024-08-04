//
//  AddMemberItem.swift
//  iosApp
//
//  Created by Hoa Tran on 11/6/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat

struct AddMemberItem: View, CreateMemberProtocol, GetGroupsSuccessProtocol {
    func execute(groups: [Group]) {
        print("Group is refreshed")
        globalVariables.groups = groups
        globalVariables.group = globalVariables.groups.first(where: {$0.group.id == globalVariables.group!.group.id})
//        groups.forEach { group in
//            group.members.forEach { m in
//                var person = m.person
//                var member = m.member
//                if (globalVariables.personByGroup[group.group.id] == nil) {
//                    globalVariables.personByGroup[group.group.id] = [:]
//                }
//                globalVariables.personByGroup[group.group.id]![member.id] = person
//                if (globalVariables.memberByPerson[group.group.id] == nil) {
//                    globalVariables.memberByPerson[group.group.id] = [:]
//                }
//                globalVariables.memberByPerson[group.group.id]![person.id] = member
//                if (!globalVariables.userFriends.contains(m.person)) {
//                    globalVariables.userFriends.insert(m.person)
//                }
//            }
//        }
    }
    
    func execute() {
        withAnimation {
            viewMembers = true
            viewAddMember = false
            //refresh the group???
            SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
        }
    }
    
    var name: String?
    var photo: String?
    var personId: String
    var isHost: Bool
    var memberId: String
    var isCurrentMember: Bool
    @Binding var viewAddMember: Bool
    @Binding var viewMembers: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    
    var body: some View {
        HStack{
            Spacer()
            CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: photo ?? ""))) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6){
                HStack{
                    Text(name ?? "")
                        .fontWeight(.semibold)
                        .padding(.top, 3)
                }
//                HStack{
//                    Text(group.group.description ?? group.latestMessage?.text ?? "")
////                        .foregroundColor(Color("color_bg_inverted").opacity(0.5))
//                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
//                }
                
                Divider()
                    .padding(.top, 8)
            }
            .padding(.horizontal, 10)
        }.onTapGesture {
            SwiftAPI.createMember(token: globalVariables.token, memberId: personId, groupId: globalVariables.group!.group.id, onSuccess: self)
            //go to profile of this member
            print("Go to the member profile")
        }
    }
}
