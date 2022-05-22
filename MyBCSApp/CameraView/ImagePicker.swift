//
//  ImagePicker.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/18/22.
//

import SwiftUI

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
