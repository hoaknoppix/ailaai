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

struct SignUpView: View, SignUpSuccessProtocol, GetGroupsSuccessProtocol, UpdateProfileSuccessProtocol {
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
    
    @Binding var showTermDialog: Bool
    let url = URL(string: "https://ailaai.app/terms")
    @Binding var signedIn: Bool
    @Binding var signedUp: Bool
    @State private var isShowingNameIsNotValid: Bool = false
    @FocusState private var nameIsFocused: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    @Environment(\.scenePhase) var scenePhase

    func execute(token: String) {
        withAnimation {
            globalVariables.token = token
            UserDefaults.standard.set(globalVariables.token, forKey: "token")
            signedIn = true
            SwiftAPI.updateProfile(token: token, name: name, onSuccess: self)
            SwiftAPI.updateDeviceToken(token: globalVariables.token, deviceToken: globalVariables.deviceToken)
        }
    }
    
    func execute(userInfo: UserInfo) {
        print("Fetching userInfo successfully!")
        globalVariables.userInfo = userInfo
        AppState.shared.isLoaded = true
    }
    
    @State private var transferCode = ""
    @State private var name = ""
    
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
                     TextField("", text: self.$name, prompt: Text(NSLocalizedString("Your Name", comment: "")).foregroundColor(.gray))
                         .foregroundColor(.black)
                         .padding()
                         .focused($nameIsFocused)
                         .background(Color.white)
                         .cornerRadius(20.0)
                     
                 }.padding([.leading, .trailing], 27.5)
                 Button(action: {
                     if name.trimmingCharacters(in: .whitespaces).isEmpty {
                         isShowingNameIsNotValid = true
                     } else {
                         showTermDialog = true
                         nameIsFocused = false
                     }
                 }) {
                     Text("Sign Up")
                         .font(.headline)
                         .foregroundColor(.white)
                         .padding()
                         .frame(width: 300, height: 50)
                         .background(Color.black)
                         .cornerRadius(15.0)
                 }.padding(.top, 50)
                 
                 Spacer()
                 HStack(spacing: 0) {
                     Text("Do you have an account? ")
                         .foregroundColor(.black)
                     Button(action: {
                         withAnimation {
                             signedUp = false
                             signedIn = false
                         }
                     }) {
                         Text("Sign In")
                             .foregroundColor(.blue)
                     }
                 }
             }
        .toast(isPresenting: $isShowingNameIsNotValid, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: NSLocalizedString("Please enter a valid name (e.g. John Appleseed)", comment: ""))
        })
        .alert(NSLocalizedString("Please read and accept our terms of use.", comment: ""), isPresented: $showTermDialog) {
            VStack {
                Button(NSLocalizedString("Read the terms", comment: ""), role: .none) {
                    showTermDialog = true
                    //FIXME: back for it
                    
                    UIApplication.shared.open(url!)
                }
                Button(NSLocalizedString("Accept the terms", comment: ""), role: .none) {
                    SwiftAPI.signUp(onSuccess: self)
                    showTermDialog = false
                }
                Button(NSLocalizedString("Go back", comment: ""), role: .none) {
                    showTermDialog = false
                }
            }
        }
        
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                showTermDialog = true
                print("1")
            } else if newPhase == .inactive {
                print("2")
            } else if newPhase == .background {
                print("3")
            }
        }
//        .alert(isPresented: $showTermDialog) {
//            Text("Hello")
//            return Alert(
//                title: Text(NSLocalizedString("Terms of Use", comment: "")),
//                message: Text(NSLocalizedString("Please read and accept our terms of use.", comment: "")),
//                primaryButton: .default(Text(NSLocalizedString("Accept", comment: ""))) {
//                    UIApplication.shared.open(url!)
//                    SwiftAPI.signUp(onSuccess: self)
//                },
//                secondaryButton: .cancel()
//            )
//        }
        .background(
            Color(.white))
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showTermDialog: .constant(false), signedIn: .constant(false), signedUp: .constant(true))
    }
}
