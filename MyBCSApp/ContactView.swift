//
//  ContactView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/20/22.
//

import SwiftUI

struct ContactView: View {
    @Binding var image: UIImage?
    @State var i1 = UIImage(named:"15.jpeg")
    
    
    
    init(image: Binding<UIImage?>) {
        _image = image
        let stringim = ImageConvertor().toBase64()
        HttpRequest(string_image: stringim).getHttpResponse()
//        print(stringim)
    }
    
    var body: some View {
        Image(uiImage: _image.wrappedValue ?? UIImage(named: "placeholder")!)
            .resizable()
            .frame(width: 300, height: 300)
//
//        Image(uiImage: self.i1.un ?? UIImage(named: "placeholder")!)
//            .resizable()
//            .frame(width: 300, height: 300)
    
    }
}

//struct ContactView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactView(image: UIImage)
//    }
//}
