import SwiftUI
//import shared

struct MemberView: View {
    
    @Binding var viewMessages: Bool
    @Binding var viewMembers: Bool
    @Binding var viewPersonProfile: Bool
    @Binding var viewAddMember: Bool
    @Binding var viewProfile: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    withAnimation {
                        viewMessages = true
                        viewMembers = false
                        viewAddMember = false
                        AppState.shared.isNotified = false
                    }
                    } label: {
                        Image(systemName: "chevron.backward")
    //                        .resizable()
                            .frame(width: 20, height: 20)
                    }
                Text("Members")
                    .font(.system(size:38, weight: .bold, design: .default))
                Spacer()
                if (globalVariables.userInfo != nil && globalVariables.memberByPerson[globalVariables.group!.group.id]![globalVariables.userInfo!.id] != nil) {
                    Image(systemName:"plus.app.fill")
                        .resizable()
                        .frame(width: 25, height:25, alignment: .center)
                        .padding(8)
                        .onTapGesture {
                            withAnimation {
                                viewAddMember = true
                                viewMembers = false
                                viewMessages = false
                            }
                        }
                }
//                Image(systemName:"person.circle.fill")
//                    .resizable()
//                    .frame(width: 25, height: 25, alignment: .center)
//                    .padding(8)
//                    .onTapGesture {
//                    }
//                Image(systemName:"rectangle.portrait.and.arrow.right")
//                    .resizable()
//                    .onTapGesture {
//                        //                        signedIn = false
////                        showingAlert = true
//                        
//                    }
//                    .frame(width: 25, height:25, alignment: .center)
//                    .padding(8)
            }
//            .alert("Add Member", isPresented: $showAddMember) {
//                //Load friend
//                ForEach(Array(globalVariables.userFriends), id: \.id) { person in
//                    MemberItem(name: person.name, photo: person.photo, personId: person.id, isHost: false, memberId: "", isCurrentMember: false, viewPersonProfile: .constant(false), viewMembers: .constant(false))
//                }
//                Button("Add", role: .cancel) {
//                    showAddMember = false
//                }
//            }
            .padding()
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading, spacing: 5){
                                    
                    VStack(spacing: 25){
                        if let group = globalVariables.group {
                            ForEach(group.members, id: \.member.id) { item in
                                if (globalVariables.userInfo != nil) {
                                    MemberItem(name: item.person.name, photo: item.person.photo, personId: item.person.id, isHost: (globalVariables.memberByPerson[globalVariables.group!.group.id]![globalVariables.userInfo!.id]?.host ?? false), memberId: item.member.id , isCurrentMember: item.member.id == globalVariables.memberByPerson[globalVariables.group!.group.id]![globalVariables.userInfo!.id]?.id, viewPersonProfile: $viewPersonProfile, viewMembers: $viewMembers, viewProfile: $viewProfile, globalVariables: _globalVariables
                                    )
                                }
                            }
                        }
                    }
                   
                }
            }
        }
	}
}

struct MemberView_Previews: PreviewProvider {
	static var previews: some View {
        MemberView(viewMessages: .constant(false), viewMembers: .constant(true), viewPersonProfile: .constant(false), viewAddMember: .constant(false), viewProfile: .constant(false))
	}
}
