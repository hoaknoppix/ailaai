import SwiftUI
import LoadingView

extension AnyTransition {
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))}
}
@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

//    @StateObject var globalVariables = GlobalVariables()
    @State var signedIn = UserDefaults.standard.value(forKey: "token") != nil
    @State var signedUp = false
    @State var viewMessages = false
    @State var viewProfile = false
    @State var viewPersonProfile = false
    @State var viewMembers = false
    @State var viewAddMember = false
    @State var selectedTab = 0
    @StateObject var appState = AppState.shared

	var body: some Scene {
		WindowGroup {
//            if (appDelegate.globalVariables.getNotified()) {
//                MessageView(viewMessages: $viewMessages).transition(.slide).environmentObject(appDelegate.globalVariables)
//            }
            if (appState.isNotified == true) {
                MessageView(viewMessages: $viewMessages, viewMembers: $viewMembers).transition(.opacity).environmentObject(appDelegate.globalVariables)
            }
            else if (!signedIn) {
                if (signedUp) {
                    SignUpView(signedIn: $signedIn, signedUp: $signedUp).transition(.opacity).environmentObject(appDelegate.globalVariables)
                } else {
                    LoginView(signedIn: $signedIn, signedUp: $signedUp).transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
            } else if appState.isLoaded {
                if (viewMessages) {
                    MessageView(viewMessages: $viewMessages, viewMembers: $viewMembers).transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
                else if (viewMembers) {
                    MemberView(viewMessages: $viewMessages, viewMembers: $viewMembers, viewPersonProfile: $viewPersonProfile, viewAddMember: $viewAddMember, viewProfile: $viewProfile).transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
                else if (viewAddMember) {
                    AddMemberView(viewMessages: $viewMessages, viewMembers: $viewMembers, viewPersonProfile: $viewPersonProfile, viewAddMember: $viewAddMember).transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
                else if (viewProfile) {
                    ProfileView(viewProfile: $viewProfile, viewMembers: $viewMembers, newName: "", newAbout: "").transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
                else if (viewPersonProfile) {
                    PersonProfileView(viewPersonProfile: $viewPersonProfile, viewMembers: $viewMembers, viewMessages: $viewMessages).transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
                else {
                    ContentView(selectedTab: $selectedTab, viewMessages: $viewMessages, signedIn: $signedIn, viewProfile: $viewProfile, viewPersonProfile: $viewPersonProfile, viewMembers: $viewMembers).transition(.opacity).environmentObject(appDelegate.globalVariables)
                }
            }
        }
//        .onReceive(Publisher, perform: <#T##(Publisher.Output) -> Void#>)
//        .onReceive(of: globalVariables.token, perform: { newToken in
//            signedIn = (newToken != "")
//        })
    }
    
}


extension iOSApp: GetGroupsSuccessProtocol {
    func execute(groups: [Group]) {
        print("Groups are refreshed")
        appDelegate.globalVariables.groups = groups
        groups.forEach { group in
            group.members.forEach { m in
                let person = m.person
                let member = m.member
                if (appDelegate.globalVariables.personByGroup[group.group.id] == nil) {
                    appDelegate.globalVariables.personByGroup[group.group.id] = [:]
                }
                appDelegate.globalVariables.personByGroup[group.group.id]![member.id] = person
                if (appDelegate.globalVariables.memberByPerson[group.group.id] == nil) {
                    appDelegate.globalVariables.memberByPerson[group.group.id] = [:]
                }
                appDelegate.globalVariables.memberByPerson[group.group.id]![person.id] = member
                if (!appDelegate.globalVariables.userFriends.contains(m.person) && (m.person.id != appDelegate.globalVariables.userInfo?.id)) {
                    appDelegate.globalVariables.userFriends.insert(m.person)
                }
            }
        }
    }
}


extension iOSApp: GetLocalGroupsSuccessProtocol {
    func execute(localgroups: [Group]) {
        print("Local Groups are refreshed")
        appDelegate.globalVariables.localgroups = localgroups
        localgroups.forEach { group in
            group.members.forEach { m in
                let person = m.person
                let member = m.member
                if (appDelegate.globalVariables.personByGroup[group.group.id] == nil) {
                    appDelegate.globalVariables.personByGroup[group.group.id] = [:]
                }
                appDelegate.globalVariables.personByGroup[group.group.id]![member.id] = person
                if (appDelegate.globalVariables.memberByPerson[group.group.id] == nil) {
                    appDelegate.globalVariables.memberByPerson[group.group.id] = [:]
                }
                appDelegate.globalVariables.memberByPerson[group.group.id]![person.id] = member
//
//                if (!appDelegate.globalVariables.userFriends.contains(m.person) && (m.person.id != appDelegate.globalVariables.userInfo?.id)) {
//                    appDelegate.globalVariables.userFriends.insert(m.person)
//                }
            }
        }
    }
}
