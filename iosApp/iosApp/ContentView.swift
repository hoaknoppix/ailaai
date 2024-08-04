import SwiftUI
import LoadingView
//import shared
//import Alamofire
//
//class Test : KotlinSuspendFunction1 {
////    func invoke(p1: Any?, completionHandler: @escaping (Any?, Error?) -> Void) {
////        print("Hello")
////    }
//
//    func invoke(p1: Any?) async throws -> Any? {
//        print("Hello:")
//    }
//
//
//}

struct ContentView: View, GetGroupsSuccessProtocol, GetLocalGroupsSuccessProtocol {
    @Binding var selectedTab: Int
    @Binding var viewMessages: Bool
    @Binding var signedIn: Bool
    @Binding var viewProfile: Bool
    @Binding var viewPersonProfile: Bool
    @Binding var viewMembers: Bool
    @State var isLoading: Bool = false
    @State private var didLoad = false
    
    func execute(groups: [Group]) {
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
                if (!globalVariables.userFriends.contains(m.person) && (m.person.id != globalVariables.userInfo?.id)) {
                    globalVariables.userFriends.insert(m.person)
                }
            }
        }
        isLoading = false
    }


    func execute(localgroups: [Group]) {
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
//
//                if (!appDelegate.globalVariables.userFriends.contains(m.person) && (m.person.id != appDelegate.globalVariables.userInfo?.id)) {
//                    appDelegate.globalVariables.userFriends.insert(m.person)
//                }
            }
        }
        isLoading = false
    }
    
    @EnvironmentObject var globalVariables: GlobalVariables
    
    var body: some View {
        TabView {

            GroupView(selectedTab: $selectedTab, viewMessages: $viewMessages, signedIn: $signedIn, viewPersonProfile: $viewPersonProfile, viewMembers: $viewMembers, viewProfile: $viewProfile, text: .constant(""), newGroupName: "")
                .environmentObject(globalVariables)
            //            .badge(2)
                .tabItem {
                    Label("", systemImage: "person.2.fill")
                }
                .onAppear {
                    if (!didLoad) {
                        print(globalVariables.groups)
                        if (selectedTab == 0) {
                            SwiftAPI.getGroups(token: globalVariables.token, onSuccess: self)
                        } else if (selectedTab == 1) {
                            SwiftAPI.getLocalGroups(token: globalVariables.token, geoString: globalVariables.currentLocation, isPublic: true, limit: 100, offset: 0, onSuccess: self)
                        }
                        didLoad = true
//                        isLoading = true
                    }
                }
//            ExploreView()
//            //            .badge(2)
//                .tabItem {
//                    Label("", systemImage: "eye.fill")
//                }
//            StoryView()
//                .tabItem {
//                    Label("", systemImage: "bookmark.fill")
//                }
        }.dotsIndicator(when: $isLoading)
    }
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
        ContentView(selectedTab: .constant(0), viewMessages: .constant(false), signedIn: .constant(true), viewProfile: .constant(false), viewPersonProfile: .constant(false), viewMembers: .constant(false))
	}
}
