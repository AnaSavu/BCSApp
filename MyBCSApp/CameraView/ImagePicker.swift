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
            isPhotoSelected = true
            
            
            let ref = FirebaseManager.shared.storage.reference(withPath: "image.jpeg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            guard let imageData = image?.jpegData(compressionQuality: 1) else {return}
            ref.putData(imageData, metadata: metadata) {
                metadata, err in
                if let err = err {
                    print("Failed to push image to storage: \(err)")
                    return
                }
                
                ref.downloadURL {url, err in
                    if let err = err {
                        print("Failed to retrieve downloadURL: \(err)")
                        return
                    }
                    
                    print("Successfully stored image woth url: \(url?.absoluteString ?? "")")
                }
            }
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
        let im = ImagePickerCoordinator(image: $image, isShown: $isShown, isPhotoSelected: $isPhotoSelected)
        return im
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

}
