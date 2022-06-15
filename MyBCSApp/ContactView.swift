//
//  ContactView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/20/22.
//

import SwiftUI
import Contacts

class ContactModel: ObservableObject {
    @Published var businessCardData: Dictionary<String, AnyObject>?
    @Published var hasDataModified = false
    
    init() {
        let group = DispatchGroup()
    
        DispatchQueue.main.async {
            let request = HttpRequest()
            request.downloadImageFromStorage {
                (str) in
                print(str)
                var serverResponse = request.getDataFromServer()
                print("ended with request")
                self.businessCardData = self.convertStringIntoDictionary(stringData: serverResponse)
              
            }
        }
    
    }
    
    func convertStringIntoDictionary(stringData: String)  -> Dictionary<String, AnyObject>{
        var convertedDataIntoDictionary: Dictionary<String, AnyObject>?
        if let data = stringData.data(using: .utf8) {
            do {
                convertedDataIntoDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        print("dictionary")
        print(convertedDataIntoDictionary)
        return convertedDataIntoDictionary!
    }
    
    func getBusinessCardData() ->Dictionary<String, AnyObject> {
        return self.businessCardData!
    }
}

struct ContactView: View {
    @Binding var image: UIImage?
//    var businessCardData: Dictionary<String, AnyObject>?
    @State private var presentAlert = false
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
        contact.givenName = self.contactModel.businessCardData?["OTHER"] as! String
        
        if self.contactModel.businessCardData?["ORGANIZATION"] != nil {
            contact.organizationName = self.contactModel.businessCardData?["ORGANIZATION"] as! String}
        
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: self.contactModel.businessCardData?["PHONE_NUMBER"] as! String))]
        
        contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: self.contactModel.businessCardData?["EMAIL"] as! String as NSString)]
        
        let address = CNMutablePostalAddress()
        address.street = self.contactModel.businessCardData?["ADDRESS"] as! String
        contact.postalAddresses = [CNLabeledValue<CNPostalAddress>(label: CNLabelWork, value: address)]
//        }
//        else
//        {
//            contact.givenName = self.person
//            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: self.phone_number))]
//            contact.organizationName = self.organization
//            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: self.email as NSString)]
//
//            let address = CNMutablePostalAddress()
//            address.street = self.address
//            contact.postalAddresses = [CNLabeledValue<CNPostalAddress>(label: CNLabelWork, value: address)]
//        }
        
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
        if self.contactModel.businessCardData?["ORGANIZATION"] == nil {
            self.contactModel.businessCardData?["ORGANIZATION"] = "unknown" as AnyObject}
        
        FirebaseManager.shared.firestore.collection("businessCard").document(identifier.uuidString).setData(["person": self.contactModel.businessCardData?["OTHER"] as! String,
                                                                                                             "organization" : self.contactModel.businessCardData?["ORGANIZATION"] as! String,
                                                                                                             "phoneNumber" : self.contactModel.businessCardData?["PHONE_NUMBER"] as! String,
                                                                                                             "address" : self.contactModel.businessCardData?["ADDRESS"] as! String,
                                                                                                             "email" : self.contactModel.businessCardData?["EMAIL"] as! String,
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
//            saveCardInformation()
            HStack{
                Text("Person:")
                Text(self.person)
            }
            HStack{
                Text("Organization:")
                Text(self.organization)
            }
            
            HStack{
                Text("Phone Number:")
                Text(self.phone_number)
            }
            
            HStack{
                Text("Address:")
                Text(self.address)
            }
            HStack{
                Text("Email:")
                Text(self.email)
            }
        }
        
        Button("+ Add to Contacts") {
            createContactWithData()
            saveBusinessCardToFirestore()
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Text("Contact was created"))
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
    }
    
}
