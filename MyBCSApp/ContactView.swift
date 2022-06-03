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
            .frame(width: 300, height: 300)
        
        Button("+ Add to Contacts") {
            let contact = CNMutableContact()
            // Name
            contact.givenName = dictionary?["PERSON"] as! String
            // Phone No.
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: dictionary?["PHONE_NUMBER"] as! String))]
            //Organization
            contact.organizationName = dictionary?["ORGANIZATION"] as! String
            //email
            
            // postal address.
            
            
            
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            do {
                try store.execute(saveRequest)
            } catch {
                print("Error occur: \(error)")
            }
            
            //current user
            guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else {
                print("Could not find firebase uid")
                return}
            //save to db
            let identifier = UUID()
            FirebaseManager.shared.firestore.collection("businessCard").document(identifier.uuidString).setData(["title": "secn",
                                                                                                                 "email" : "2@cdf.com", "organization" : "cds", "phoneNumber" : "5432235643", "userId" : currentUserId ,
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
        .buttonStyle(.borderedProminent)
        .tint(.black)
    
    }
}

//struct ContactView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactView(image: UIImage)
//    }
//}
