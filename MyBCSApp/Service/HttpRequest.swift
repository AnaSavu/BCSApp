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
    var serverRes: String?
    var storageImage: UIImage?
    
    init(){
    }
    
    func downloadImageFromStorage(completion: @escaping((String?) -> ())){
        print("It began the downloading process")
        let imageReference = FirebaseManager.shared.storage.reference(withPath: "image.jpeg")
        
        imageReference.getData(maxSize: 10 * 1024 * 1024) {
            data, error in
            if let error = error {
                print("error downloading image \(error)")
                completion(nil)
                return
                
            } else {
                self.storageImage = UIImage(data: data!)
                print("Sucsessfully downloaded image from storage")
                completion("image downloaded")
            }
        }
        
    }
    
    func wrapper () {
        downloadImageFromStorage {
            (str) in
            self.getDataFromServer()
        }
    }
    
    
    func getDataFromServer() -> String{
        print("Image is being sent to the server")
        guard let url = URL(string: "http://192.168.0.124:8000/image") else {
            print("url was not done correctly")
            return "";
        }
        
        let imageData = self.storageImage?.jpegData(compressionQuality: 1)
        
        var request = URLRequest(url: url)
        let semaphore = DispatchSemaphore.init(value: 0)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "base64str": imageData?.base64EncodedString()
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        var serverResponse: String = ""
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print ("httpResponse.statusCode: \(httpResponse.statusCode)")
                defer {
                    semaphore.signal()
                }
            }
            else {
                do {
                    let response: String = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                    serverResponse = response
                    defer {semaphore.signal()}
                }
                catch {
                    print(error)
                }}
        }
        task.resume()
        semaphore.wait()
        print("Data from image was successfully retrieved")
        return serverResponse
    }
}
