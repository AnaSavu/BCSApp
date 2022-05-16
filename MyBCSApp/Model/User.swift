//
//  User.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/16/22.
//

import Foundation

struct User {
    let uid, email: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
}
