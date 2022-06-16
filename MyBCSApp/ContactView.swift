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
                print(serverResponse)
                print("ended with request")
                var serverDict = self.convertStringIntoDictionary(stringData: serverResponse)!
                self.businessCardData = self.compareAndAddNecessaryFields(data: serverDict)
                group.leave()
                
            }
        }
        group.notify(queue: .main) {
            self.hasDataModified = true
        }
        
    }
    
    func compareAndAddNecessaryFields(data: [String:String]) -> [String: String] {
        var d = data
        let keyEx = data["OTHER"] != nil
        if keyEx == false {
            d["OTHER"] = "unknown"
        }
        
        let k1 = data["ORGANIZATION"] != nil
        if k1 == false {
            d["ORGANIZATION"] = "unknown"
        }
        
        let k2 = data["PHONE_NUMBER"] != nil
        if k2 == false {
            d["PHONE_NUMBER"] = "unknown"
        }
        
        let k3 = data["ADDRESS"] != nil
        if k3 == false {
            d["ADDRESS"] = "unknown"
        }
        
        let k4 = data["EMAIL"] != nil
        if k4 == false {
            d["EMAIL"] = "unknown"
        }
        
        return d
        
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
        
        if self.contactModel.businessCardData["ORGANIZATION"] != "unknown" {
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
