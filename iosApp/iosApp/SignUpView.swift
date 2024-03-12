//
//  LoginView.swift
//  iosApp
//
//  Created by Hoa Tran on 11/20/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import Alamofire

struct SignUpView: View, SignUpSuccessProtocol, GetGroupsSuccessProtocol, UpdateProfileSuccessProtocol {
    func execute(groups: [Group]) {
        print("Groups are loaded")
        globalVariables.groups = groups
        groups.forEach { group in
            group.members.forEach { m in
                var person = m.person
                var member = m.member
                if (globalVariables.personByGroup[group.group.id] == nil) {
                    globalVariables.personByGroup[group.group.id] = [:]
                }
                globalVariables.personByGroup[group.group.id]![member.id] = person
            }
        }
    }
    
    @Binding var signedIn: Bool
    @Binding var signedUp: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    func execute(token: String) {
        print("SignUp successfully!")
        globalVariables.token = token
        signedIn = true
        SwiftAPI.updateProfile(token: token, name: name, onSuccess: self)
        SwiftAPI.updateDeviceToken(token: globalVariables.token, deviceToken: globalVariables.deviceToken)
    }
    
    func execute(userInfo: UserInfo) {
        print("Fetching userInfo successfully!")
        globalVariables.userInfo = userInfo
    }
    
    @State private var transferCode = ""
    @State private var name = ""

//    init() {

//        var token = ""
//        let parameters: [String: Any] = [
//            "code" : "l0HbWk3o2TJmlQV0"
//        ]
//        AF.request("https://api.ailaai.app/sign/in", method: .post, parameters: parameters, encoding: JSONEncoding.default)
//            .responseJSON { response in
//                switch (response.result) {
//                case .success(let result):
//                    let json = result as! NSDictionary
//                    token = json["token"] as! String
//                    let headers: HTTPHeaders = [.authorization(bearerToken: token)]
//                    AF.request("https://api.ailaai.app/groups", method: .get, parameters: parameters, encoder: JSONEncoding.default, headers: headers)
//                        .responseJSON { response in
//                            print(response)
//                        }
//                case .failure(_):
//                    print("Oops")
//                }
//                print("Hello")
//                let json = response.result
//                print(json.token)
//                if response.data != nil {
//                    print(response.data )
////                  let json = JSON(data: response.data!)
////                  let name = json["token"].string
////                  if name != nil {
////                    print(name!)
////                  }
//                }
//            }
        
//        AF.request("https://api.ailaai.app/sign/in", method: .post).responseJSON { AFDataResponse<Any> in
//            <#code#>
//        }
        //l0HbWk3o2TJmlQV0
//        var completionHandlers: [(Error?) -> Void] = []
//
//        var api: Api = Api()
//        api.signIn(transferCode: "l0HbWk3o2TJmlQV0", onError: nil, onSuccess: Test(), completionHandler: completionHandlers[0])
//        api.signIn(transferCode: "l0HbWk3o2TJmlQV0", onError: nil, onSuccess: Test()) { _ in
//            print("Oops")
//        }
//    let api = Api()
//    api.baseUrl = "Hello"
//    api.signIn(transferCode: String, onError: nil, onSuccess: nil, completionHandler: nil)

//    let greet = Greeting().greet()

    var body: some View {
        
        VStack() {
                 Text("Ai La Ai")
                     .font(.largeTitle).foregroundColor(Color.white)
                     .padding([.top, .bottom], 40)
                     .shadow(radius: 10.0, x: 20, y: 10)
            Image(uiImage: UIImage(named: "ailaai")!)
                     .resizable()
                     .frame(width: 250, height: 250)
                     .clipShape(Circle())
                     .overlay(Circle().stroke(Color.white, lineWidth: 4))
                     .shadow(radius: 10.0, x: 20, y: 10)
                     .padding(.bottom, 50)
                 
                 VStack(alignment: .leading, spacing: 15) {
                     TextField("Your Name", text: self.$name)
                         .padding()
                         .background(Color.themeTextField)
                         .cornerRadius(20.0)
                         .shadow(radius: 10.0, x: 20, y: 10)
                     
                 }.padding([.leading, .trailing], 27.5)
                 
                 Button(action: {
                     print("\(self.transferCode)")
                     SwiftAPI.signUp(code: transferCode, onSuccess: self)
//                     GlobalVariables.token =
                 }) {
                     Text("Sign Up")
                         .font(.headline)
                         .foregroundColor(.white)
                         .padding()
                         .frame(width: 300, height: 50)
                         .background(Color.green)
                         .cornerRadius(15.0)
                         .shadow(radius: 10.0, x: 20, y: 10)
                 }.padding(.top, 50)
                 
                 Spacer()
                 HStack(spacing: 0) {
                     Text("Do you have an account? ")
                     Button(action: {
                         signedUp = false
                         signedIn = false
                     }) {
                         Text("Sign In")
                             .foregroundColor(.blue)
                     }
                 }
             }
        .background(
            LinearGradient(gradient: Gradient(colors: [.gray, .black]), startPoint: .top, endPoint: .bottom)
                     .edgesIgnoringSafeArea(.all))
//             .background(
//                 LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
//                     .edgesIgnoringSafeArea(.all))
             
//        TabView {
//
//            GroupView(text: .constant(""))
//            //            .badge(2)
//                .tabItem {
//                    Label("", systemImage: "person.2.fill")
//                }
//            ExploreView()
//            //            .badge(2)
//                .tabItem {
//                    Label("", systemImage: "eye.fill")
//                }
//            StoryView()
//                .tabItem {
//                    Label("", systemImage: "bookmark.fill")
//                }
//        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(signedIn: .constant(false), signedUp: .constant(true))
    }
}
