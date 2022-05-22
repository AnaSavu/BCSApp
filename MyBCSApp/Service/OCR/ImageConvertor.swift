//
//  ImageConvertor.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/17/22.
//

import Foundation
import UIKit
import SwiftUI

class ImageConvertor {
    let image = UIImage(named: "MyPhoto")
//    @Binding var image: UIImage?
//
    init(){
        
    }
    
    func toBase64() -> String {
        let encoded_image = image?.jpegData(compressionQuality: 1)?.base64EncodedString()
        return encoded_image ?? ""
    }
}
