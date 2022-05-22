//
//  HttpRequest.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/17/22.
//

import Foundation

struct JsonData: Codable {
    
}

class HttpRequest {
    let string_image: String
//    let d1: String
    
    
    init(string_image: String) {
        self.string_image = string_image
    }
    
    private func getApiKey() -> String {
        if let path = Bundle.main.path(forResource: "apikey", ofType: "txt")
        {
                let fm = FileManager()
                let exists = fm.fileExists(atPath: path)
                if(exists){
                    let content = fm.contents(atPath: path)
                    let contentAsString = String(data: content!, encoding: String.Encoding.utf8)!
                    return contentAsString
                    
                }
        }
        return ""
    }
    
    func getHttpResponse() {
        let apikey = getApiKey()
        let newapiKey = apikey.components(separatedBy: .whitespacesAndNewlines).joined()
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(newapiKey)")!
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let body = self.d1.data(using: .utf8)!
//        let bodyData = try?  JSONSerialization.data(withJSONObject: body, options: [])
//        print(bodyData)
//
//
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response,error  in
//
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let
//                    jsonData = data
//                    else {
//                print("error")
//                return
//            }
//        }
//        task.resume()
    }
    
    
}
