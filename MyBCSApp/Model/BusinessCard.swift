//
//  BusinessCard.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/18/22.
//

import Foundation

struct BusinessCard: Identifiable {
    var id: String
    var userId: String
    var person: String
    var organization: String
    var phoneNumber: String
    var address: String
    var email: String
    
    init(id: String, userId: String, person: String, organization: String, phoneNumber: String, address: String, email: String) {
        self.id = id
        self.userId = userId
        self.person = person
        self.organization = organization
        self.phoneNumber = phoneNumber
        self.address = address
        self.email = email
    }
}

