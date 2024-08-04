import SwiftUI
//import shared

struct AddMemberView: View {
    
    @Binding var viewMessages: Bool
    @Binding var viewMembers: Bool
    @Binding var viewPersonProfile: Bool
    @Binding var viewAddMember: Bool
    @State private var showAddMember = false
    @EnvironmentObject var globalVariables: GlobalVariables
    

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    withAnimation {
                        viewMessages = false
                        viewMembers = true
                        viewAddMember = false
                        AppState.shared.isNotified = false
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                    //                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Text("Add Member")
                    .font(.system(size:38, weight: .bold, design: .default))
                Spacer()
//                Image(systemName:"plus.app.fill")
//                    .resizable()
//                    .frame(width: 25, height:25, alignment: .center)
//                    .padding(8)
//                    .onTapGesture {
//                        showAddMember = true
//                        viewMembers = false
//                        viewMessages = false
//                    }
//                    .padding()
            }
            .padding()
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading, spacing: 5){
                    
                    VStack(spacing: 25){
                        ForEach(Array(globalVariables.userFriends.filter({ p in
                            return !globalVariables.group!.members.contains { m in
                                m.person.id == p.id
                            }
                        })), id: \.id) { item in
                            AddMemberItem(name: item.name, photo: item.photo, personId: item.id, isHost: false,memberId: "" , isCurrentMember: false, viewAddMember: $viewAddMember, viewMembers: $viewMembers, globalVariables: _globalVariables
                            )}
                    }
                }
            }
        }
	}
}
