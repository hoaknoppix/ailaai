import SwiftUI
import ExyteChat
import CodeScanner
import AlertToast
import LoadingView
//import shared

struct GroupView: View, GetGroupsSuccessProtocol, GetLocalGroupsSuccessProtocol, GetJoinRequestSuccessProtocol, GetPersonProfileSuccessProtocol {
    func execute(personProfile: PersonProfile) {
        globalVariables.personProfile = personProfile
        globalVariables.isFromMemberScreen = false
        withAnimation {
            viewPersonProfile = true
        }
    }
    
    func execute(joinRequests: [GetJoinRequest]) {
        globalVariables.joinRequests = joinRequests
        isLoading = false
    }
    
    func execute(localgroups: [Group]) {
        print("Local Groups are refreshed")
        globalVariables.localgroups = localgroups
        localgroups.forEach { group in
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
//                if (!globalVariables.userFriends.contains(m.person) || (m.person.id != globalVariables.userInfo?.id)) {
//                    globalVariables.userFriends.insert(m.person)
//                }
            }
        }
        SwiftAPI.getJoinRequests(token: globalVariables.token, onSuccess: self)
    }
    func execute(groups: [Group]) {
        print("Groups are refreshed")
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
                if (!globalVariables.userFriends.contains(m.person) || (m.person.id != globalVariables.userInfo?.id)) {
                    globalVariables.userFriends.insert(m.person)
                }
            }
        }
        SwiftAPI.getJoinRequests(token: globalVariables.token, onSuccess: self)
    }
    
    
    @Binding var selectedTab: Int
    @Binding var viewMessages: Bool
    @Binding var signedIn: Bool
    @Binding var viewPersonProfile: Bool
    @Binding var viewMembers: Bool
    @State private var showingAlert = false
    @State private var showingGroupCreation = false
    @State private var isShowingScanner = false
    @State private var showingConfirmToViewProfileQR = false
    @Binding var viewProfile: Bool
    @State private var isLoading = false
    @ObservedObject var locationManager = LocationManager()

    @EnvironmentObject var globalVariables: GlobalVariables

    @Binding var text: String
    @State var newGroupName: String
    @State var showToastInvalidQR: Bool = false

    let tabs: [Tab] = [
        .init(icon: Image(systemName: ""), title: String(localized: "Friends")),
        .init(icon: Image(systemName: ""), title: NSLocalizedString("Local", comment: "")),
    ]
    
    

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
                Image(systemName:"qrcode.viewfinder")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .center)
                    .padding(8)
                    .onTapGesture {
                        //show camera
                        isShowingScanner = true
                    }
                CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: globalVariables.userInfo?.photo ?? ""))) { image in
                    image
                        .resizable()
//                        .scaledToFill()
                        .clipShape(.circle)
                        .padding(4)
//                        .background {
//                            Image(systemName: "person.circle.fill")
////                            Circle()
////                                .foregroundStyle(.background)
//                        }
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(8)
//                    Circle().fill(Color.gray)
                }
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .onTapGesture {
                    globalVariables.isFromMemberScreen = false
                    withAnimation {
                        viewProfile = true
                    }
                }

//                Image(systemName:"person.circle.fill")
//                    .resizable()
//                    .frame(width: 25, height: 25, alignment: .center)
//                    .padding(8)
//                    .onTapGesture {
//                        viewProfile = true
//                    }
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
                            if (!isLoading) {
                                FriendView(viewMessages: $viewMessages, viewMembers: $viewMembers)
                                    .environmentObject(globalVariables)
                                    .tag(0)
                                LocalView(viewMessages: $viewMessages)
                                    .environmentObject(globalVariables)
                                    .tag(1)
                            }
                        })
                        .dotsIndicator(when: $isLoading)
                            .onAppear(perform: {
                                if (selectedTab == 0) {
                                    isLoading = true
                                    SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                                } else if (selectedTab == 1) {
                                    isLoading = true
                                    if let location = locationManager.location {
                                        let lat = Double(location.latitude)
                                        let long = Double(location.longitude)
                                        let geoString = "\(lat),\(long)"
                                        globalVariables.currentLocation = geoString
                                    }
                                    SwiftAPI.getLocalGroups(token: globalVariables.token, geoString: globalVariables.currentLocation, isPublic: true, limit: 100, offset: 0, onSuccess: self)
                                }
                            })
                            .onChange(of: selectedTab, perform: { newValue in
                            if (newValue == 0) {
                                isLoading = true
                                SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                            } else if (newValue == 1) {
                                isLoading = true
                                if let location = locationManager.location {
                                    let lat = Double(location.latitude)
                                    let long = Double(location.longitude)
                                    let geoString = "\(lat),\(long)"
                                    globalVariables.currentLocation = geoString
                                }
                                SwiftAPI.getLocalGroups(token: globalVariables.token, geoString: globalVariables.currentLocation, isPublic: true, limit: 100, offset: 0, onSuccess: self)
                            }
                        })
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    //                           .ignoresSafeArea()
                }
            }
        }
        .toast(isPresenting: $showToastInvalidQR, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: NSLocalizedString("This is not a valid AiLaAi's QR code", comment: ""))
        })
        .sheet(isPresented: $isShowingScanner, content: {
            CodeScannerView(codeTypes: [.qr], manualSelect: true, showViewfinder: true, simulatedData: "", completion: handleScan)
        })
        .alert("Do you want to sign out?", isPresented: $showingAlert) {
            Button("OK", role: .none) {
                signedIn = false
                globalVariables.token = ""
                UserDefaults.standard.removeObject(forKey: "token")
                showingAlert = false
                AppState.shared.isLoaded = false
                globalVariables.userInfo = nil
                globalVariables.userFriends = Set<Person>()
                globalVariables.userProfile = nil
            }
            Button("Cancel", role: .cancel) {
                showingAlert = false
            }
        }
        .alert("New Group", isPresented: $showingGroupCreation) {
            TextField("Group Name", text: $newGroupName)
            Button("OK", role: .none) {
                //create new group
                SwiftAPI.createGroup(token: globalVariables.token, groupName: newGroupName, onSuccess: self)
                showingGroupCreation = false
            }
            Button("Cancel", role: .cancel) {
                showingGroupCreation = false
            }
        }
        .alert("Would you like to go to your profile?", isPresented: $showingConfirmToViewProfileQR) {
//            TextField("Group Name", text: $newGroupName)
            Button("OK", role: .none) {
                showingConfirmToViewProfileQR = false
                globalVariables.isFromMemberScreen = false
                viewProfile = true
            }
            Button("Cancel", role: .cancel) {
                //do nothing
                showingConfirmToViewProfileQR = false
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
        GroupView(selectedTab: .constant(0), viewMessages: .constant(false), signedIn: .constant(true), viewPersonProfile: .constant(false), viewMembers: .constant(false), viewProfile: .constant(false), text: .constant(""), newGroupName: "")
	}
}

extension GroupView : CreateGroupsSuccessProtocol {
    func onCreateNewGroupSuccess(groupId: String) {
        print("Hello new group created")
        //do nothing
    }
    
    func onUpdateNameNewGroupSuccess(groupId: String, groupName: String) {
        print("Hello new name created")
        //do nothing
        SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
    }
}

extension GroupView {
    func handleScan(result: Result<ScanResult, ScanError>) {
       // more code to come
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            if (details[0].contains("\(SwiftAPI.endPoint)/profile")) {
                let personId = String(details[0].split(separator: "/")[3])
                if personId == globalVariables.userInfo?.id {
//                    globalVariables.isFromMemberScreen = false
//                    viewProfile = true
                    showingConfirmToViewProfileQR = true
                }
                else {
                    SwiftAPI.getPersonProfile(token: globalVariables.token, personId: personId, onSuccess: self)
                }
            } else {
                showToastInvalidQR = true
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}
