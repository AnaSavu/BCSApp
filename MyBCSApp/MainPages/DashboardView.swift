//
//  DashboardView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/12/22.
//

import SwiftUI
import FirebaseStorage



struct DashboardView: View {
    
    //for sign out
    @State var shouldShowLogOutOptions = false
    
    
    //for image picker
    @State var shouldShowImagePickerActionSheet = false
    @State var shouldShowImagePicker = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    @State private var image: UIImage?
    @State private var isPhotoSelected: Bool = false
    
    @State private var presentAlert = false
    
    @ObservedObject private var dashboardModel: DashboardModel
    @ObservedObject var businessCardsModel: BusinessCardsModel
    
    @Environment(\.dismiss) private var dismiss
    
    init() {
        self.dashboardModel = DashboardModel()
        self.businessCardsModel = .init()
    }
    
    private var newBusinessCardButton: some View {
        Button(action: {
            shouldShowImagePickerActionSheet.toggle()
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
            .actionSheet(isPresented: $shouldShowImagePickerActionSheet) {
                ActionSheet(title: Text("Select Photo"), message: Text("Choose"), buttons: [
                    .default(Text("Photo Library")) {
                        shouldShowImagePicker.toggle()
                        self.sourceType = .photoLibrary
                    },
                    .default(Text("Camera")) {
                        shouldShowImagePicker.toggle()
                        self.sourceType = .camera
                    },
                    .cancel()
                ])
            }
        })
        .frame(maxHeight: 15, alignment: .bottom)
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            VStack {
                ImagePicker(image: self.$image, isPhotoSelected: self.$isPhotoSelected, sourceType: self.sourceType)
                    .fullScreenCover(isPresented: self.$isPhotoSelected) {
                        ContactView(image: self.$image)
                    }
                
                
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
            }
            .overlay(newBusinessCardButton, alignment: .bottom)
            .navigationBarHidden(true)
            
        }.navigationBarHidden(true)
    }
    
    private var dashboardView: some View {
        ScrollView {
            VStack {
                ForEach(self.businessCardsModel.businessCards) {card in
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
                            self.deleteBusinessCardFromStorage(cardId: card.id)
                            
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
    
    private func deleteBusinessCardFromStorage(cardId: String) {
        FirebaseManager.shared.firestore.collection("businessCard").document(cardId).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document \(cardId) successfully removed!")
                presentAlert = true
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
                Text("\(dashboardModel.user?.email ?? "")")
                    .font(.system(size: 24, weight: .bold))
                
                
            }
            
            Spacer()
//            NavigationLink(destination: LoginView(didCompleteLoginProcess: {
//                self.dashboardModel.isUserCurrentlyLoggenOut = false
//                self.dashboardModel.fetchCurrentUser()}),
//                           isActive: $dashboardModel.isUserCurrentlyLoggenOut,
//                           label: {Button {
//                                shouldShowLogOutOptions.toggle()
//                            } label: {
//                                Image(systemName: "gear")
//                                    .font(.system(size: 24, weight: .bold))
//                                    .foregroundColor(Color(.label))
//                            }}
//            )
            
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
                    dashboardModel.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $dashboardModel.isUserCurrentlyLoggenOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.dashboardModel.isUserCurrentlyLoggenOut = false
                self.dashboardModel.fetchCurrentUser()
            })
        }
    }
    
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
