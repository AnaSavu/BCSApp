//
//  ContactView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/20/22.
//

import SwiftUI
import Contacts

class ContactModel: ObservableObject {
    @Published var businessCardData: [String:String] = [:]
    @Published var hasDataModified = false
    
    
    init() {
        self.businessCardData = ["OTHER": "unknown", "ORGANIZATION": "unkown", "PHONE_NUMBER": "unknown", "ADDRESS": "unknown", "EMAIL": "unknown"]
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async(flags: .barrier) {
            
            let request = HttpRequest()
            request.downloadImageFromStorage {
                (str) in
                var serverResponse = request.getDataFromServer()
                print("ended with request")
                self.businessCardData = self.convertStringIntoDictionary(stringData: serverResponse)!
                group.leave()
                
            }
        }
        group.notify(queue: .main) {
            self.hasDataModified = true
        }
        
    }
    
    func convertStringIntoDictionary(stringData: String)  -> [String:String]? {
        if let data = stringData.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:String]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    @State private var presentAlert = false
    @State private var shouldShowDashboardView = false
    var hasModelChanged = false
    @ObservedObject var contactModel = ContactModel()
    var person = "ana"
    var phone_number = "897"
    var address = "fwfw"
    var organization = "vd"
    var email = "cd@d"
    var data: String?

    
    init(image: Binding<UIImage?>) {
        _image = image
    }
    
    
    
    func createContactWithData() {
        let contact = CNMutableContact()
        // Name
        //        if self.contactModel.hasDataModified == true {
        contact.givenName = self.contactModel.businessCardData["OTHER"]!
        
        if self.contactModel.businessCardData["ORGANIZATION"] != nil {
            contact.organizationName = self.contactModel.businessCardData["ORGANIZATION"]! }
        
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: self.contactModel.businessCardData["PHONE_NUMBER"]! ))]
        
        contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: self.contactModel.businessCardData["EMAIL"] as! NSString)]
        
        let address = CNMutablePostalAddress()
        address.street = self.contactModel.businessCardData["ADDRESS"]!
        contact.postalAddresses = [CNLabeledValue<CNPostalAddress>(label: CNLabelWork, value: address)]
        
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
            presentAlert = true
        } catch {
            print("Error occur: \(error)")
        }
    }
    
    func saveBusinessCardToFirestore() {
        //current user
        guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Could not find firebase uid")
            return}
        //save to db
        let identifier = UUID()
        if self.contactModel.businessCardData["ORGANIZATION"] == nil {
            self.contactModel.businessCardData["ORGANIZATION"] = "unknown" as AnyObject as? String}
        
        FirebaseManager.shared.firestore.collection("businessCard").document(identifier.uuidString).setData(["person": self.contactModel.businessCardData["OTHER"]!,
                                                                                                             "organization" : self.contactModel.businessCardData["ORGANIZATION"] ,
                                                                                                             "phoneNumber" : self.contactModel.businessCardData["PHONE_NUMBER"] ,
                                                                                                             "address" : self.contactModel.businessCardData["ADDRESS"] ,
                                                                                                             "email" : self.contactModel.businessCardData["EMAIL"] ,
                                                                                                             "userId" : currentUserId ,
                                                                                                             "id":identifier.uuidString
                                                                                                            ]) {
            error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    var body: some View {
        Image(uiImage: _image.wrappedValue ?? UIImage(named: "placeholder")!)
            .resizable()
            .frame(width: 250, height: 400)
        
        Form {
            HStack{
                Text("Person:")
                Text(self.contactModel.businessCardData["OTHER"]!)
            }
            HStack{
                Text("Organization:")
                Text(self.contactModel.businessCardData["ORGANIZATION"]!)
            }
            
            HStack{
                Text("Phone Number:")
                Text(self.contactModel.businessCardData["PHONE_NUMBER"]!)
            }
            
            HStack{
                Text("Address:")
                Text(self.contactModel.businessCardData["ADDRESS"]!)
            }
            HStack{
                Text("Email:")
                Text(self.contactModel.businessCardData["EMAIL"]!)
            }
        }
        
        Button("+ Add to Contacts") {
            createContactWithData()
            saveBusinessCardToFirestore()
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Text("Contact was created"), primaryButton: .default(Text("OK")) {dismiss()}, secondaryButton: .cancel())
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
    }
    
}
