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

struct DashboardView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @State var shouldShowCameraScreen = false
    @State var showImagePicker = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    
    
    @State var b1: BusinessCard = BusinessCard(id: "1", title: "t1", email: "a@", phoneNumber: "43")
    @State var businessCards: [BusinessCard] = []
    
    @State private var image: UIImage?
    
    @ObservedObject private var vm = DashboardModel()
    
    private var newBusinessCardButton: some View {
        Button {
            shouldShowCameraScreen.toggle()
        }
        label : {
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
            .actionSheet(isPresented: $shouldShowCameraScreen) {
                ActionSheet(title: Text("Select Photo"), message: Text("Choose"), buttons: [
                    .default(Text("Photo Library")) {
                        self.showImagePicker = true
                        self.sourceType = .photoLibrary
                    },
                    .default(Text("Camera")) {
                        self.showImagePicker = true
                        self.sourceType = .camera
                    },
                    .cancel()
                ])
            }
            
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                dashboardView
            }
            .overlay(newBusinessCardButton, alignment: .bottom)
            .navigationBarHidden(true)
            
        }
    }
    
    private var businessCardRow: some View {
        //        var businessCard: BusinessCard
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "lanyardcard")
                    .font(.system(size: 32))
                    .rotationEffect(.degrees(270))
                VStack(alignment: .leading){
                    Text("businessCard.title")
                        .font(.system(size: 16, weight: .bold))
                    Text("businessCard.email")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)

                    Text("businessCard.phoneNumber")
                        .font(.system(size: 14))
                }
                Spacer()

            }
            Divider()
                .padding(.vertical, 8)
        }.padding(.horizontal)
    }
    
    private var dashboardView: some View {
        ScrollView {
//            print("Get documents is executing \(getDocs())")
//            print(self.businessCards)
            VStack {
            }
            .onAppear {
                getDocs()
                ForEach(0..<self.businessCards.count) {_ in
                    businessCardRow
                }.padding(.bottom, 50)
            }
            
        }
    }
    
    private func getDocs() {
        FirebaseManager.shared.firestore.collection("businessCard")
//            .whereField("id", isEqualTo: self.vm.user?.uid)
            .getDocuments() {
//            .whereField("userId", arrayContains: [self.vm.user?.uid]).getDocuments()
            (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.businessCards.append(self.b1)
            
            DispatchQueue.main.async {
                
                self.businessCards = documents.map {
                    (QueryDocumentSnapshot) -> BusinessCard in
                    let data = QueryDocumentSnapshot.data()
                    print("data")
                    print(data)
                    
                    let id = data["id"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let phoneNumber = data["phoneNumber"] as? String ?? ""
                    
                    
                    return BusinessCard(id: id, title: title, email: email, phoneNumber: phoneNumber)
                }
            }
            print(self.businessCards)
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
    
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
        //            .preferredColorScheme(.dark)
    }
}
