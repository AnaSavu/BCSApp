//
//  ContactView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/20/22.
//

import SwiftUI
import Contacts

struct ContactView: View {
    @Binding var image: UIImage?
    @State var i1 = UIImage(named:"15.jpeg")
    var dictionary: Dictionary<String, AnyObject>?
    @State private var presentAlert = false
  
    init(image: Binding<UIImage?>) {
        _image = image
        var stringRes = HttpRequest(image: self.$image).apiCall()
        
        if let data = stringRes.data(using: .utf8) {
            do {
                dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        print(dictionary)

    }
    
    var body: some View {
        Image(uiImage: _image.wrappedValue ?? UIImage(named: "placeholder")!)
            .resizable()
            .frame(width: 250, height: 400)
        
        Form {
            HStack{
                Text("Person:")
                Text(dictionary?["OTHER"] as! String)
            }
            HStack{
                Text("Organization:")
                Text(dictionary?["ORGANIZATION"] as! String)
            }
            
            HStack{
                Text("Phone Number:")
                Text(dictionary?["PHONE_NUMBER"] as! String)
            }
            
            HStack{
                Text("Address:")
                Text(dictionary?["ADDRESS"] as! String)
            }
            HStack{
                Text("Email:")
                Text(dictionary?["EMAIL"] as! String)
            }
        }
        
        Button("+ Add to Contacts") {
            let contact = CNMutableContact()
            // Name
            contact.givenName = dictionary?["OTHER"] as! String
            // Phone No.
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: dictionary?["PHONE_NUMBER"] as! String))]
            //Organization
            contact.organizationName = dictionary?["ORGANIZATION"] as! String
            //email
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: dictionary?["EMAIL"] as! String as NSString)]
            // postal address.
            let address = CNMutablePostalAddress()
            address.street = dictionary?["ADDRESS"] as! String
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
            
            //current user
            guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Could not find firebase uid")
                return}
            //save to db
            let identifier = UUID()
            FirebaseManager.shared.firestore.collection("businessCard").document(identifier.uuidString).setData(["person": dictionary?["OTHER"] as! String,
                                                                                                                 "organization" : dictionary?["ORGANIZATION"] as! String,
                                                                                                                 "phoneNumber" : dictionary?["PHONE_NUMBER"] as! String,
                                                                                                                 "address" : dictionary?["ADDRESS"] as! String,
                                                                                                                 "email" : dictionary?["EMAIL"] as! String,
                                                                                                                 "userId" : currentUserId ,
                                                                                                                 "id":identifier.uuidString
                                                                                                  ]) {
                err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
            }
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Text("Contact was created"))
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
    
    }
}
