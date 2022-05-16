//
//  MyBCSAppApp.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/12/22.
//

import SwiftUI
import Firebase

@main
struct MyBCSAppApp: App {
    
    var body: some Scene {
        WindowGroup {
            LoginView(didCompleteLoginProcess: {})
        }
    }
}
