//
//  ImageAnalyzerView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/09.
//

import SwiftUI
import VisionKit

@MainActor
struct ImageAnalyzerView: UIViewRepresentable {

    let image: UIImage
    let imageView = LiveImageView()
//    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()


    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.addInteraction(interaction)
//        interaction.preferredInteractionTypes = .imageSubject
        imageView.contentMode = .scaleAspectFit
        return imageView

    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let image = imageView.image else {return}

    }
}

class LiveImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        .zero
    }

}


