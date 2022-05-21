//
//  ContactView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/20/22.
//

import SwiftUI

struct ContactView: View {
    @Binding var image: UIImage?
    
    init(image: Binding<UIImage?>) {
        _image = image
        print(image)
    }
    
    var body: some View {
        Image(uiImage: _image.wrappedValue ?? UIImage(named: "placeholder")!)
            .resizable()
            .frame(width: 300, height: 300)
    
    }
}

//struct ContactView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactView(image: UIImage)
//    }
//}
