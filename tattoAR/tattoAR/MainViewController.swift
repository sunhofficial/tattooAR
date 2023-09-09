//
//  VisionViewController.swift
//  tattoAR
//
//  Created by 235 on 2023/09/09.
//

import UIKit
import VisionKit
import SnapKit

class MainViewController: UIViewController {
    enum ImageSource {
        case camera
        case gallery
    }
    let photoImageView = UIImageView()
    let imagePicker = UIImagePickerController()
    var hoverGestureRecognizer: UIHoverGestureRecognizer?
    let selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Image", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        imagePicker.delegate = self
    }

    func configureUI() {
        photoImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        photoImageView.center = view.center
        photoImageView.contentMode = .scaleAspectFit
        view.addSubview(photoImageView)
        selectButton.center.x = view.center.x
        selectButton.center.y = view.center.y + 150
        selectButton.addTarget(self, action: #selector(selectButtonTouched), for: .touchUpInside)
        view.addSubview(selectButton)
    }

    @objc func selectButtonTouched() {
        let alert = UIAlertController(title: "Choose Image", message:  nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openImagePicker(source: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openImagePicker(source: .gallery )
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var newImage : UIImage? = nil // update 할 이미지

        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage    // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage        // 원본 이미지가 있을 경우
        }
        self.photoImageView.image = newImage
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension MainViewController {
    private func openImagePicker(source: ImageSource) {
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .gallery:
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
}
