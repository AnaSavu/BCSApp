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
  
    init(image: Binding<UIImage?>) {
        _image = image
//        let stringim = ImageConvertor().toBase64()
//        HttpRequest(string_image: stringim).getHttpResponse()
        HttpRequest(image: self.$image).apiCall()
        
//        var dictonary:NSDictionary?
//
//        if let data = response.data(using: String.Encoding.utf8.rawValue) {
//            do {
//                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
//                print(dictonary)
//            } catch let error as NSError {
//                print(error)
//            }
//        }

    }
    
    var body: some View {
        Image(uiImage: _image.wrappedValue ?? UIImage(named: "placeholder")!)
            .resizable()
            .frame(width: 300, height: 300)
        
        Button("+ Add to Contacts") {
            let contact = CNMutableContact()
            // Name
            contact.givenName = "Ming"
            // Phone No.
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: "12345678"))]
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            do {
                try store.execute(saveRequest)
            } catch {
                print("Error occur: \(error)")
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
