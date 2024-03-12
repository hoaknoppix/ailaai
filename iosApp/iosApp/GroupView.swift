import SwiftUI
import shared

struct GroupView: View {
    
    @State private var selectedTab: Int = 0
    @Binding var viewMessages: Bool
    @Binding var signedIn: Bool
    @State private var showingAlert = false
    @State private var showingGroupCreation = false

    @EnvironmentObject var globalVariables: GlobalVariables


    let tabs: [Tab] = [
        .init(icon: Image(systemName: ""), title: "Friends"),
//        .init(icon: Image(systemName: ""), title: "Local"),
    ]


    @Binding var text: String
    @Binding var newGroupName: String
    
    

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Groups")
                    .font(.system(size:38, weight: .bold, design: .default))
                Spacer()
                Image(systemName:"plus.app.fill")
                    .resizable()
                    .frame(width: 25, height:25, alignment: .center)
                    .padding(8)
                    .onTapGesture {
                        showingGroupCreation = true
                    }
                Image(systemName:"rectangle.portrait.and.arrow.right")
                    .resizable()
                    .onTapGesture {
                        //                        signedIn = false
                        showingAlert = true
                        
                    }
                    .frame(width: 25, height:25, alignment: .center)
                    .padding(8)
                //                Image(systemName:"ellipsis.circle")
                //                    .resizable()
                //                    .frame(width: 25, height:25, alignment: .center)
                //                    .padding(8)
                //
                //                Image(systemName:"qrcode.viewfinder")
                //                    .resizable()
                //                    .frame(width: 25, height: 25, alignment: .center)
                //                    .padding(8)
                //
                //                Image(systemName:"person.circle.fill")
                //                    .resizable()
                //                    .frame(width: 25, height: 25, alignment: .center)
                //                    .padding(8)
                
            }
            .padding()
            
            //            TextField("Search...", text: $text)
            //                .padding(7)
            //                .background(Color(.systemGray5))
            //                .cornerRadius(13)
            //                .padding(.horizontal, 15)
            NavigationView {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        // Tabs
                        Tabs(tabs: tabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
                        
                        // Views
                        TabView(selection: $selectedTab,
                                content: {
                            FriendView(viewMessages: $viewMessages)
                                .environmentObject(globalVariables)
                                .tag(0)
                            LocalView()
                                .tag(1)
                        })
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    //                           .ignoresSafeArea()
                }
            }
        }
        .alert("Do you want to sign out?", isPresented: $showingAlert) {
            Button("OK", role: .none) {
                signedIn = false
                showingAlert = false
            }
            Button("Cancel", role: .cancel) {
                showingAlert = false
            }
        }
        .alert("New Group", isPresented: $showingGroupCreation) {
            TextField("Group Name", text: $newGroupName)
            Button("OK", role: .none) {
                //create new group
                showingGroupCreation = false
            }
            Button("Cancel", role: .cancel) {
                showingGroupCreation = false
            }
        }
//        .alert(isPresented: $showingAlert, error: LocalizedError?) {
//            //1. Create the alert controller.
//            let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)
//
//            //2. Add the text field. You can configure it however you need.
//            alert.addTextField { (textField) in
//                textField.text = "Some default text"
//            }
//
//            // 3. Grab the value from the text field, and print it when the user clicks OK.
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//                print("Text field: \(textField?.text)")
//            }))
//
//            // 4. Present the alert.
//            self.present(alert, animated: true, completion: nil)
//        }
	}
}

struct GroupView_Previews: PreviewProvider {
	static var previews: some View {
        GroupView(viewMessages: .constant(false), signedIn: .constant(true), text: .constant(""), newGroupName: .constant(""))
	}
}
