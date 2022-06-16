//
//  BusinessCardsModel.swift
//  MyBCSApp
//
//  Created by Ana Savu on 6/16/22.
//

import Foundation

class BusinessCardsModel: ObservableObject {
    @Published var businessCards = [BusinessCard]()
    
    let user: User?
    
    init(user: User?) {
        print("user \(user?.uid)")
        self.user = user
        getBusinessCards()
    }
    
    func getBusinessCards() {
        print("Items are fetched")
        FirebaseManager.shared.firestore.collection("businessCard")
            .getDocuments() {
                (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No businessCards")
                    return
                }

                DispatchQueue.main.async {
                    
                    for document in documents {
                        let data = document.data()
                        
                        let id = data["id"] as? String ?? ""
                        let userId = data["userId"] as? String ?? ""
                        let person = data["person"] as? String ?? ""
                        let organization = data["organization"] as? String ?? ""
                        let phoneNumber = data["phoneNumber"] as? String ?? ""
                        let address = data["address"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        
                        if userId == self.user?.uid {
                            self.businessCards.append(
                                .init(id: id, userId: userId, person: person, organization: organization, phoneNumber: phoneNumber, address: address, email: email))
                        }
                    }
                    
                }
            }
        
        print(self.businessCards)
    }
}
