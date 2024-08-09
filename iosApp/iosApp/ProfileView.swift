//
//  ProfileView.swift
//  AiLaAi
//
//  Created by Hoa Tran on 6/2/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import ExyteChat
import PhotosUI
import QRCode
import LoadingView

struct ProfileView: View, UpdateProfileSuccessProtocol, GetProfileSuccessProtocol, TransferSuccessProtocol, GetUserInfoSuccessProtocol, UpdatePhotoSuccessProtocol, RemoveAccountSuccessProtocol {
    func getQR(text: String) -> Data {
        let image = try! QRCode.build
            .text(text)
            .quietZonePixelCount(3)
            .foregroundColor(UIColor.darkGray.cgColor)
            .backgroundColor(UIColor.white.cgColor)
            .background.cornerRadius(3)
            .onPixels.shape(QRCode.PixelShape.Star())
            .eye.shape(QRCode.EyeShape.Edges())
            .generate.image(dimension: 600, representation: .png())
        return image
    }
    
    func doAfterRemove() {
        signedIn = false
        globalVariables.token = ""
        UserDefaults.standard.removeObject(forKey: "token")
        showingDeleteConfirmation = false
        AppState.shared.isLoaded = false
        globalVariables.userInfo = nil
        globalVariables.userFriends = Set<Person>()
        globalVariables.userProfile = nil
    }
    
    func execute() {
        SwiftAPI.getUserProfile(token: globalVariables.token, onSuccess: self)
        SwiftAPI.getUserInfo(token: globalVariables.token, onSuccess: self)
    }
    
    func execute(code: String) {
        UIPasteboard.general.string = code
        showingTransferCodeCopied = true
    }
    
    func execute(userProfile: UserProfile) {
        globalVariables.userProfile = userProfile
    }
    
    func execute(userInfo: UserInfo) {
        globalVariables.userInfo = userInfo
        isLoading = false
    }
    
    @Binding var signedIn: Bool
    @Binding var viewProfile: Bool
    @Binding var viewMembers: Bool
    @EnvironmentObject var globalVariables: GlobalVariables
    @State private var showingNameCreation = false
    @State private var showingAboutCreation = false
    @State private var showingUpdatePhoto = false
    @State private var showingTransferCodeCopied = false
    @State private var showingDeleteConfirmation = false
    @State var newName: String
    @State var newAbout: String = "New About"
    @State var isLoading: Bool = false
    @State private var avatarImage: Image?
    @State private var avatarItem: PhotosPickerItem?
    
    var body: some View {
        
            VStack() {
                PhotosPicker(selection: $avatarItem, matching: .images, photoLibrary: .shared()) {
                    CachedAsyncImage(url: URL(string: SwiftAPI.getImageUrl(path: globalVariables.userInfo?.photo ?? ""))) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                            .padding(4)
                            .background {
                                Circle()
                                    .foregroundStyle(.background)
                            }
                    } placeholder: {
                        Rectangle().fill(Color.gray)
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                }.dotsIndicator(when: $isLoading)
                
                VStack(alignment: .leading, spacing: 15) {
                    Button {
                        showingNameCreation = true
                    } label: {
                        Text(globalVariables.userInfo?.name ?? "").font(.title).bold()
                    }
                    
                }.padding([.leading, .trailing], 27.5)
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        if (!showingAboutCreation) {
                            Text(.init(globalVariables.userProfile?.about ?? "")).font(.subheadline).bold()
                                .textSelection(.enabled)
                        } else {
                            TextEditor(text: $newAbout)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
                                .padding()
                                .border(Color.gray, width: 1)
                                .cornerRadius(5.0)
                                .padding()
                        }
                    }.padding([.leading, .trailing], 27.5)
                    Spacer()
                    Spacer()
                }
                VStack {
                    if let id = globalVariables.userInfo?.id {
                        Image(uiImage: UIImage(data: getQR(text: "\(SwiftAPI.endPoint)/profile/\(id)"))!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                }
                VStack {
                    Button(action: {
                        if (showingAboutCreation) {
                            showingAboutCreation = false
                            SwiftAPI.updateProfile(token: globalVariables.token, about: newAbout, onSuccess: self)
                        } else {
                            showingAboutCreation = true
                            newAbout = globalVariables.userProfile?.about ?? ""
                        }
                    }) {
                        Text(showingAboutCreation ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Update Bio", comment: ""))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.black)
                            .cornerRadius(15.0)
                    }
                    
                    if (!showingAboutCreation) {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Text("Delete Account")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.black)
                                .cornerRadius(15.0)
                        }
                        Button(action: {
                            SwiftAPI.transferCode(token: globalVariables.token, onSuccess: self)
                        }) {
                            Text("Copy transfer code")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.black)
                                .cornerRadius(15.0)
                        }
                        Button(action: {
                            withAnimation {
                                viewProfile = false
                                if (globalVariables.isFromMemberScreen) {
                                    viewMembers = true
                                }
                            }
                        }) {
                            Text("Go back")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.black)
                                .cornerRadius(15.0)
                        }
                    }
                }
                Spacer()
            }
            .onChange(of:avatarItem) { newValue in
                Task {
                    isLoading = true
                    if let image = try? await avatarItem?.loadTransferable(type: Data.self) {
                        SwiftAPI.updatePhoto(token: globalVariables.token, photo: image, onSuccess: self)
                    } else {
                        print("Failed")
                        isLoading = false
                    }
                }
            }
//            .onChange(of: avatarItem) {
//                Task {
//                    isLoading = true
//                    if let image = try? await avatarItem?.loadTransferable(type: Data.self) {
//                        SwiftAPI.updatePhoto(token: globalVariables.token, photo: image, onSuccess: self)
//                    } else {
//                        print("Failed")
//                        isLoading = false
//                    }
//                }
//            }
            .alert("Name", isPresented: $showingNameCreation) {
                TextField("New Name", text: $newName)
                Button("OK", role: .none) {
                    SwiftAPI.updateProfile(token: globalVariables.token, name: newName, onSuccess: self)
                    showingNameCreation = false
                }
                Button("Cancel", role: .cancel) {
                    showingNameCreation = false
                }
            }
            .alert(NSLocalizedString("Do you want to delete this account?", comment: ""), isPresented: $showingDeleteConfirmation) {
                Button("OK", role: .none) {
                    SwiftAPI.removeAccount(token: globalVariables.token, onSuccess: self)
                }
                Button("Cancel", role: .cancel) {
                    showingDeleteConfirmation = false
                }
            }
            .alert(isPresented: $showingTransferCodeCopied) {
                Alert(
                    title: Text("Transfer Code is copied"),
                    message: Text("Please save it for future login."),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}
