//
//  HttpRequest.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/17/22.
//

import Foundation
import UIKit
import SwiftUI
import SDWebImageSwiftUI

class HttpRequest {
    
    init(){
    }
    
    func downloadImageFromStorage(){
        print("it has gow here")
        let imageReference = FirebaseManager.shared.storage.reference(withPath: "demo.jpeg")
        
        imageReference.getData(maxSize: 5 * 1024 * 1024) {
            data, error in
              if let error = error {
                  print("error downloading image \(error)")
                  return
                  
              } else {
                  let image = UIImage(data: data!)
                  print("image successfully downloaded")
              }
        }
        
    }
    
    func getDataFromServer() -> String {
        downloadImageFromStorage()
        guard let url = URL(string: "http://192.168.0.124:8000/image") else {
            print("url was not done correctly")
            return "";
        }

        let image = UIImage(named: "MyPhoto")
        let imageData = image?.jpegData(compressionQuality: 1)
  
        var request = URLRequest(url: url)
        let semaphore = DispatchSemaphore.init(value: 0)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "base64str": imageData?.base64EncodedString()
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        var serverResponse: String = ""

        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let response: String = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                serverResponse = response
                defer {semaphore.signal()}
            }
            catch {
                print(error)
            }
        }
        task.resume()
        semaphore.wait()
        return serverResponse
    }
}
