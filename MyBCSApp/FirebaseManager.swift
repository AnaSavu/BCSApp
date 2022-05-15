//
//  FirebaseManager.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/15/22.
//

import Foundation
import Firebase

class FirebaseManager : NSObject {
    let auth: Auth
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
