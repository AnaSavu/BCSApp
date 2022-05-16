//
//  LoginView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/12/22.
//

import SwiftUI
import Firebase

struct LoginView: View {
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var hasLoggenIn = false
    
    
//    init() {
//        FirebaseApp.configure()
//    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        
                    if !isLoginMode {
                        Button {
                            
                        } label : {
                            Image(systemName: "person.fill")
                            .font(.system(size: 34))
                            .padding()
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                
                        SecureField("Password", text: $password)
                           
                    }.padding(12)
                    
                    
                    
                    Button {
                        handleAction()
                    } label : {
                        HStack {
                            Spacer()  
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            Spacer()
                        }.background(Color.blue)
                        
                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                    NavigationLink(destination: DashboardView(), isActive: $hasLoggenIn, label: {EmptyView()})
                    
                }.padding()
               
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
            print("Should log in Firebase with existing credentials")
        }
        else {
            createNewAccount()
//            print("Register a new account inside of Firebase Auth")
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to login user", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            print("Successfully logged in as user user: \(result?.user.uid ?? "")")
            hasLoggenIn = true
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            storeUserInformation()
        }
    }
    
    private func storeUserInformation() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userdata = ["email": self.email, "uid": uid]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userdata) {
                err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                self.didCompleteLoginProcess()
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {})
    }
}
