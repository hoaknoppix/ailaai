//
//  LocalView.swift
//  iosApp
//
//  Created by Hoa Tran on 11/2/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct LocalView: View {

    @EnvironmentObject var globalVariables: GlobalVariables
    @Binding var viewMessages: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .leading, spacing: 5){
                
//                SearchView(searchText: $searchText)
                if (globalVariables.localgroups.isEmpty) {
                    Text(NSLocalizedString("Sorry currently there is no local groups in your location.", comment: ""))
                }
                VStack(spacing: 25){
                    
                    ForEach(globalVariables.localgroups, id: \.group.id) { group in
                        ContactItem(viewMessages: $viewMessages,
                                    group: group
                    )}
                }
               
            }
        }
    }
}

struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView(viewMessages: .constant(false))
    }
}
