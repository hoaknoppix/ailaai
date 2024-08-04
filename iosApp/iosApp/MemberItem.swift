//
//  MemberItem.swift
//  iosApp
//
//  Created by Hoa Tran on 11/6/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat

struct MemberItem: View, GetPersonProfileSuccessProtocol, LeaveGroupProtocol, GetGroupsSuccessProtocol {
    func execute(groups: [Group]) {
        print("Group is refreshed")
        globalVariables.groups = groups
        globalVariables.group = globalVariables.groups.first(where: {$0.group.id == globalVariables.group!.group.id})
    }
    
    func leave() {
        //do nothing
        SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
    }
    
    func execute(personProfile: PersonProfile) {
        withAnimation {
            globalVariables.personProfile = personProfile
            viewPersonProfile = true
            viewMembers = false
        }
    }
    
    var name: String?
    var photo: String?
    var personId: String
    var isHost: Bool
    var memberId: String
    var isCurrentMember: Bool
    @Binding var viewPersonProfile: Bool
    @Binding var viewMembers: Bool
    @Binding var viewProfile: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    @State private var showingAlert: Bool = false
    let removeStr = NSLocalizedString("Do you want to remove", comment: "")
    
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
            if (!isCurrentMember && isHost) {
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Remove")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100, height: 40)
                        .background(Color.black)
                        .cornerRadius(15.0)
                    //                    .shadow(radius: 10.0, x: 20, y: 10)
                }
            }
        }.onTapGesture {
            withAnimation {
                if (personId == globalVariables.userInfo?.id) {
                    viewProfile = true
                    viewMembers = false
                } else {
                    SwiftAPI.getPersonProfile(token: globalVariables.token, personId: personId, onSuccess: self)
                }
            }
            //go to profile of this member
        }
//        .alert("Do you want to remove this member?", isPresented: $showingAlert) {
        .alert("\(removeStr) \(name!)?", isPresented: $showingAlert) {
            Button("OK", role: .none) {
                SwiftAPI.leaveGroup(token: globalVariables.token, memberId: memberId, onSuccess: self)
                showingAlert = false
            }
            Button("Cancel", role: .cancel) {
                showingAlert = false
            }
        }
    }
}
