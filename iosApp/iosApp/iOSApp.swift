import SwiftUI

@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

//    @StateObject var globalVariables = GlobalVariables()
    @State var signedIn = false
    @State var signedUp = false
    @State var viewMessages = false
    @ObservedObject var appState = AppState.shared

	var body: some Scene {
		WindowGroup {
//            if (appDelegate.globalVariables.getNotified()) {
//                MessageView(viewMessages: $viewMessages).transition(.slide).environmentObject(appDelegate.globalVariables)
//            }
            if (appState.isNotified == true) {
                MessageView(viewMessages: $viewMessages).transition(.slide).environmentObject(appDelegate.globalVariables)
            }
            else if (!signedIn) {
                if (signedUp) {
                    SignUpView(signedIn: $signedIn, signedUp: $signedUp).environmentObject(appDelegate.globalVariables)
                } else {
                    LoginView(signedIn: $signedIn, signedUp: $signedUp).environmentObject(appDelegate.globalVariables)
                }
            }
            else if (viewMessages) {
                MessageView(viewMessages: $viewMessages).transition(.slide).environmentObject(appDelegate.globalVariables)
            }
            else {
                ContentView(viewMessages: $viewMessages, signedIn: $signedIn).environmentObject(appDelegate.globalVariables).onAppear {
                    withAnimation(.easeInOut(duration: 2)) {
                        //do nohting
                        SwiftAPI.getGroups(token: appDelegate.globalVariables.token, onSuccess: self)
                        print("do nohting")
                    }
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
                var person = m.person
                var member = m.member
                if (appDelegate.globalVariables.personByGroup[group.group.id] == nil) {
                    appDelegate.globalVariables.personByGroup[group.group.id] = [:]
                }
                appDelegate.globalVariables.personByGroup[group.group.id]![member.id] = person
            }
        }
    }
}
