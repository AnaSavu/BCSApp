//
//  ImagePicker.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/18/22.
//

import SwiftUI
import FirebaseStorage

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    @Binding var isPhotoSelected: Bool
    
    init(image: Binding<UIImage?>, isShown: Binding<Bool>, isPhotoSelected: Binding<Bool>) {
        _image = image
        _isShown = isShown
        _isPhotoSelected = isPhotoSelected
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            image = uiImage
            isShown = false
            
            
            let group = DispatchGroup()
        
            group.enter()
            DispatchQueue.main.async {
                self.uploadImageToStorage {
                    (str) in
                    print("gothere")
                    self.isPhotoSelected = true
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.isPhotoSelected = true
            }
        }
    }
    
    func uploadImageToStorage(completion: @escaping((String?) -> ())) {
        let imageReference = FirebaseManager.shared.storage.reference(withPath: "image.jpeg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let imageData = image?.jpegData(compressionQuality: 1) else {return}
        imageReference.putData(imageData, metadata: metadata) {
            metadata, error in
            if let error = error {
                print("Failed to push image to storage: \(error)")
                completion(nil)
                return
            }
            print("Successfully pushed image to storage")
            completion("Successfully pushed image to storage")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
        isPhotoSelected = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator
    
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    @Binding var isPhotoSelected: Bool
    
    var sourceType: UIViewControllerType.SourceType = .camera
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        let image = ImagePickerCoordinator(image: $image, isShown: $isShown, isPhotoSelected: $isPhotoSelected)
        return image
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

}
