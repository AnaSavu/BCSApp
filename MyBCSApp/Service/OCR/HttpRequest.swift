//
//  HttpRequest.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/17/22.
//

import Foundation
import UIKit
import SwiftUI

class HttpRequest {
    @Binding var image: UIImage?
    
    init(image: Binding<UIImage?>){
        _image = image
    }
    
    func apiCall(){
        guard let url = URL(string: "http://192.168.1.8:8000/image") else {
            print("url was not done correctly")
            return
        }
        
        let im = UIImage(named: "MyPhoto")
        let imData = im?.jpegData(compressionQuality: 1)
//        let imData = _image.wrappedValue?.jpegData(compressionQuality: 1)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "base64str": imData?.base64EncodedString()
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let response: NSString = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSString
                print("SUCCESS: \(response)")
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}
