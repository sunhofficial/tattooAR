//
//  ImagePickerSelectView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/10.
//

import UIKit
import SnapKit
import VisionKit
class ImagePickerSelectView: UIViewController {
    let imageView = UIImageView()
    var selectedImage: UIImage?
    let interaction = ImageAnalysisInteraction()
    init(selectedImage: UIImage?) {
          self.selectedImage = selectedImage
          super.init(nibName: nil, bundle: nil)
      }

      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        imageView.image = selectedImage
        imageView.addInteraction(interaction)
        interaction.preferredInteractionTypes = .imageSubject
        // 이미지 뷰 설정
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}


