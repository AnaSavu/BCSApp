//
//  BusinessCardsModel.swift
//  MyBCSApp
//
//  Created by Ana Savu on 6/16/22.
//

import Foundation

class BusinessCardsModel: ObservableObject {
    @Published var businessCards = [BusinessCard]()
    
    let uid: String
    
    init(uid: String) {
        self.uid = uid
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
                DispatchQueue.main.async {
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
}
