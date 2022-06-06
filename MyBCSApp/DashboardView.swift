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
    
    
//    @State var b1: BusinessCard = BusinessCard(id: "1", title: "t1", email: "a@", phoneNumber: "43")
    @State var businessCards: [BusinessCard] = []
    
    @State private var image: UIImage?
    @State private var presentAlert = false
    
    @State private var isPhotoSelected: Bool = false
    
    @ObservedObject private var vm = DashboardModel()
    
    private var newBusinessCardButton: some View {
        Button(action: {
            shouldShowCameraScreen.toggle()
        }, label: {
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
        })
        .frame(maxHeight: 15, alignment: .bottom)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: self.$image, isShown: self.$showImagePicker, isPhotoSelected: self.$isPhotoSelected, sourceType: self.sourceType)
                .sheet(isPresented: self.$isPhotoSelected){
                    ContactView(image: self.$image)
                }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                dashboardView
            }
            .onAppear {
//                removeAllC
                getDocs()
                
            }
            .overlay(newBusinessCardButton, alignment: .bottom)
            .navigationBarHidden(true)
            
        }.navigationBarHidden(true)
    }
    
    private var dashboardView: some View {
        ScrollView {
            VStack {
                ForEach(self.businessCards) {card in
                    HStack(spacing: 16) {
                        Image(systemName: "lanyardcard")
                            .font(.system(size: 32))
                            .rotationEffect(.degrees(270))
                        VStack(alignment: .leading){
                            HStack {
                                Text("Person")
                                Spacer()
                                Text(card.person)
                                .font(.system(size: 16, weight: .bold))
                            }
                            HStack{
                                Text("Organization")
                                Spacer()
                                Text(card.organization)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                            }
                            HStack{
                                Text("Phone Number")
                                Spacer()
                                Text(card.phoneNumber)
                                    .font(.system(size: 14))
                            }
                            HStack {
                                Text("Address")
                                Spacer()
                                Text(card.address)
                                    .font(.system(size: 14))
                            }
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(card.email)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                            }
                           
                        }
                        Spacer()

                        Button {
                            self.deleteCard(cardId: card.id)
                            
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(.label))
                        }
                        .alert(isPresented: $presentAlert) {
                            Alert(title: Text("Business card was successfully removed!"))
                        }

                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.bottom, 15)
            }
            .padding(.horizontal)
            
        }
    }
    
    private func deleteCard(cardId: String) {
        FirebaseManager.shared.firestore.collection("businessCard").document(cardId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document \(cardId) successfully removed!")
                presentAlert = true
            }
        }
    }
    
    private func getDocs() {
        FirebaseManager.shared.firestore.collection("businessCard")
            .getDocuments() {
            (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            DispatchQueue.main.async {
                var temporaryBusinessCardsList: [BusinessCard] = []
                
                for d in documents {
                    let data = d.data()
                    
                    let id = data["id"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let person = data["person"] as? String ?? ""
                    let organization = data["organization"] as? String ?? ""
                    let phoneNumber = data["phoneNumber"] as? String ?? ""
                    let address = data["address"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    
                    
                    
                    
                    if userId == self.vm.user?.uid {
                        temporaryBusinessCardsList.append(BusinessCard(id: id, userId: userId, person: person, organization: organization,  phoneNumber: phoneNumber, address: address, email: email))
                    }
                }
                
                self.businessCards = temporaryBusinessCardsList
                print("data")
                print(self.businessCards)
            }
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
