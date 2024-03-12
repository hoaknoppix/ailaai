//
//  GlobalVariables.swift
//  iosApp
//
//  Created by Hoa Tran on 11/21/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation
import ExyteChat
import SwiftUI

class GlobalVariables : ObservableObject {
    @Published var token = ""
    @Published var groups: [Group] = []
    @Published var messages: [MessageDTO] = []
    @Published var uiMessages: [Message] = []
    @Published var group: Group? = nil
    @Published var userInfo: UserInfo? = nil
    @Published var personByGroup: [String: [String : Person]] = [:]
    @Published var deviceToken = ""
}
