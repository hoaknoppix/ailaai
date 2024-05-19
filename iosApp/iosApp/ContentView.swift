import SwiftUI
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

struct ContentView: View, GetGroupsSuccessProtocol {
    @Binding var viewMessages: Bool
    @Binding var signedIn: Bool
    func execute(groups: [Group]) {
        print(groups)
    }
    
    @EnvironmentObject var globalVariables: GlobalVariables
    
    var body: some View {
        TabView {

            GroupView(viewMessages: $viewMessages, signedIn: $signedIn, text: .constant(""), newGroupName: .constant("" ))
                .environmentObject(globalVariables)
            //            .badge(2)
                .tabItem {
                    Label("", systemImage: "person.2.fill")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
        ContentView(viewMessages: .constant(false), signedIn: .constant(true))
	}
}
