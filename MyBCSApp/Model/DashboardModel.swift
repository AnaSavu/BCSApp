//
//  DashboardModel.swift
//  BECAS
//
//  Created by Ana Savu on 6/16/22.
//

import Foundation

class DashboardModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var user: User?
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggenOut = FirebaseManager.shared.auth
                .currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return}
        
        FirebaseManager.shared.firestore.collection("users").document(userId).getDocument {snapshot, error in
            
            if let error = error {
                self.errorMessage = "Failed fetching current user: \(error)"
                print("Failed fetching current user: ", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return}
            
            self.user = .init(data: data)
            
        }
        
    }
    
    @Published var isUserCurrentlyLoggenOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggenOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
