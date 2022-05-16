//
//  DashboardView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/12/22.
//

import SwiftUI

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
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return}
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {snapshot, error in
            
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

struct BusinessCard: Identifiable {
    var id: ObjectIdentifier
    var title: String
    var email: String
    var phoneNumber: String
}

struct DashboardView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = DashboardModel()
    
    var body: some View {
        NavigationView {
            VStack {
//                Text("CURRENT USER ID: \(vm.user?.uid ?? "") ")
                customNavBar
                dashboardView
            }
            .overlay(newBusinessCardButton, alignment: .bottom)
            .navigationBarHidden(true)
            
        }
    }
    
    private var customNavBar: some View {
        HStack {
            Image(systemName: "person.fill")
                .font(.system(size: 24, weight: .heavy))
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
            VStack(alignment: .leading) {
                Text("\(vm.user?.email ?? "")")
                    .font(.system(size: 24, weight: .bold))
            
                
            }
        
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
//                        .default(Text("DEFAULT BUTTON")),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggenOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggenOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    private var dashboardView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "lanyardcard")
                            .font(.system(size: 32))
                            .rotationEffect(.degrees(270))
                        VStack(alignment: .leading){
                            Text("Title")
                                .font(.system(size: 16, weight: .bold))
                            Text("Email")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray)
                                
                            Text("Phone Number")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    
    private var newBusinessCardButton: some View {
        Button {
            
        } label : {
            HStack {
                Spacer()
                Text("+ New Business Card")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
            
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}
