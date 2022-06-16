//
//  BusinessCardsModel.swift
//  MyBCSApp
//
//  Created by Ana Savu on 6/16/22.
//

import Foundation

class BusinessCardsModel: ObservableObject {
    @Published var businessCards: [BusinessCard] = []
    
    var uid: String?
    
    init() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return}
        print(userId)
        self.uid = userId
        getBusinessCards()
    }
    
    func getBusinessCards() {
        FirebaseManager.shared.firestore.collection("businessCard")
            .addSnapshotListener {
                (querySnapshot, error) in
                if let error = error {
                    print("Failed to listed to database")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({change in
                    let data = change.document.data()
                    
                    let id = data["id"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let person = data["person"] as? String ?? ""
                    let organization = data["organization"] as? String ?? ""
                    let phoneNumber = data["phoneNumber"] as? String ?? ""
                    let address = data["address"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    
                    if change.type == .added {
                        
                        
                        if userId == self.uid {
                            self.businessCards.append(
                                .init(id: id, userId: userId, person: person, organization: organization, phoneNumber: phoneNumber, address: address, email: email))
                        }
                    }
                    
                    if change.type == .removed {
                        let removed_pos = self.businessCards.firstIndex(where: {$0.userId == self.uid})
                        self.businessCards.remove(at: removed_pos!)
                    }
                })
            }
    }
}
