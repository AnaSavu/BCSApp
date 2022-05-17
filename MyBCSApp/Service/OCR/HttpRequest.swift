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
    let data = """
    {
        "requests": [
          {
            "features": [
              {
                "maxResults": 50,
                "type": "OBJECT_LOCALIZATION"
              },
              {
                "maxResults": 50,
                "type": "LABEL_DETECTION"
              },
              {
                "maxResults": 50,
                "model": "builtin/latest",
                "type": "DOCUMENT_TEXT_DETECTION"
              },
              {
                "maxResults": 50,
                "type": "SAFE_SEARCH_DETECTION"
              }
            ],
            "image": {
              "content": self.__image
            },
            "imageContext": {
              "cropHintsParams": {
                "aspectRatios": [
                  0.8,
                  1,
                  1.2
                ]
              }
            }
          }
        ]
    }
    """
    
    init(string_image: String) {
        self.string_image = string_image
    }
    
    private func getApiKey() -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = dir.appendingPathComponent("apikey.txt")
            
            do  {
                let text = try String(contentsOf: fileUrl, encoding: .utf8)
                return text
            }
            catch {
                print("Error retrieving apikey")
                return ""
            }
        }
        return ""
    }
    
    func getHttpResponse() {
        let apikey = getApiKey()
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=" + apikey)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
    
    
}
