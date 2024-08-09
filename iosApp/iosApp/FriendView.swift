//
//  FriendView.swift
//  iosApp
//
//  Created by Hoa Tran on 11/2/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI


var messages = [[
"user": "Hoa",
"photo": "https://upload.wikimedia.org/wikipedia/commons/5/56/Donald_Trump_official_portrait.jpg",
"message": "This is a message"
],
                ["user":  "Jacob",
                 "photo": "https://upload.wikimedia.org/wikipedia/commons/5/56/Donald_Trump_official_portrait.jpg",
                "message": "Hi, are you ready for the meeting?"]]

struct FriendView: View {

    @EnvironmentObject var globalVariables: GlobalVariables
    @Binding var viewMessages: Bool
    @Binding var viewMembers: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading, spacing: 5){
                
//                SearchView(searchText: $searchText)
                
                if (globalVariables.groups.isEmpty) {
                    Text(NSLocalizedString("You will see the converation of your groups and your friends here.", comment: ""))
                } else {
                    VStack(spacing: 25){
                        ForEach(globalVariables.groups, id: \.group.id) { group in
                            ContactItem(viewMessages: $viewMessages, group: group)
                        }
                    }
                }
               
            }
        }
    }
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        FriendView(viewMessages: .constant(false), viewMembers: .constant(false))
    }
}
