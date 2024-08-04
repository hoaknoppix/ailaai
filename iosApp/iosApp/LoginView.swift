//
//  LoginView.swift
//  iosApp
//
//  Created by Hoa Tran on 11/20/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import Alamofire
import AlertToast

extension Color {
    static var themeTextField: Color {
        return Color.black
        //return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}

struct LoginView: View, SignInSuccessProtocol, GetGroupsSuccessProtocol, GetUserInfoSuccessProtocol, GetProfileSuccessProtocol, SignInFailureProtocol {
    func execute(userProfile: UserProfile) {
        globalVariables.userProfile = userProfile
    }
    
    func execute(groups: [Group]) {
        print("Groups are loaded")
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
    }
    
    @Binding var signedIn: Bool
    @Binding var signedUp: Bool
    @State private var isShowingTransferCodeIsNotValid: Bool = false
    @FocusState private var nameIsFocused: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    
    func execute(error: String) {
        isShowingTransferCodeIsNotValid = true
    }
    
    func execute(token: String) {
        withAnimation {
            globalVariables.token = token
            UserDefaults.standard.set(globalVariables.token, forKey: "token")
            signedIn = true
            signedUp = false
            SwiftAPI.getUserInfo(token: globalVariables.token, onSuccess: self)
            SwiftAPI.getUserProfile(token: globalVariables.token, onSuccess: self)
            SwiftAPI.updateDeviceToken(token: globalVariables.token, deviceToken: globalVariables.deviceToken)
        }
    }
    
    func execute(userInfo: UserInfo) {
        print("Fetching userInfo successfully!")
        globalVariables.userInfo = userInfo
        AppState.shared.isLoaded = true
    }
    
    @State private var transferCode = ""

    var body: some View {
        
        VStack() {
                 Text("Ai La Ai")
                     .font(.largeTitle).foregroundColor(Color.black)
                     .padding([.top, .bottom], 40)
                     .onTapGesture {
                         nameIsFocused = false
                     }
            Image(uiImage: UIImage(named: "ailaai")!)
                     .resizable()
                     .frame(width: 250, height: 250)
                     .clipShape(Circle())
                     .overlay(Circle().stroke(Color.white, lineWidth: 4))
                     .padding(.bottom, 50)
                     .onTapGesture {
                         nameIsFocused = false
                     }
                 
                 VStack(alignment: .leading, spacing: 15) {
                     TextField("", text: self.$transferCode, prompt: Text(NSLocalizedString("Transfer Code", comment: "")).foregroundColor(.gray))
                         .foregroundColor(.black)
                         .padding()
                         .focused($nameIsFocused)
                         .background(Color.white)
                         .cornerRadius(20.0)
                     
                 }.padding([.leading, .trailing], 27.5)
                 
                 Button(action: {
                     print("\(self.transferCode)")
                     SwiftAPI.signIn(code: transferCode, onSuccess: self, onFailure: self)
                     nameIsFocused = false
                 }) {
                     Text("Sign In")
                         .font(.headline)
                         .foregroundColor(.white)
                         .padding()
                         .frame(width: 300, height: 50)
                         .background(Color.black)
                         .cornerRadius(15.0)
                 }.padding(.top, 50)
                 
                 Spacer()
                 HStack(spacing: 0) {
                     Text("Don't have an account? ")
                         .foregroundColor(.black)
                     Button(action: {
                         withAnimation {
                             signedUp = true
                             signedIn = false
                         }
                     }) {
                         Text("Sign Up")
                             .foregroundColor(.blue)
                     }
                 }
             }
        .background(
            Color(.white))
        .toast(isPresenting: $isShowingTransferCodeIsNotValid, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: NSLocalizedString("Log in failed.", comment: ""))
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(signedIn: .constant(false), signedUp: .constant(false))
    }
}
