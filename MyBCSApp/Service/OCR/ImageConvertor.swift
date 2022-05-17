//
//  ImageConvertor.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/17/22.
//

import Foundation
import UIKit

class ImageConvertor {
    let image = UIImage(named: "15.jpeg")?.jpegData(compressionQuality: 1)
    
    init(){
    }
    
    func toBase64() -> String {
        let image_string = self.image?.base64EncodedString()
        print(image_string ?? "Could not encode image to base64")
        return image_string ?? ""
    }
}
