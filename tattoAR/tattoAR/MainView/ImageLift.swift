//
//  ImageLift.swift
//  tattoAR
//
//  Created by 235 on 2023/09/10.


import SwiftUI
import VisionKit

@MainActor
struct ImageLift: UIViewRepresentable {
    var selectImage: UIImage
    let imageView = LiftImageView()
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    @State var location: CGPoint = .zero
    @Binding var objectImage: UIImage
    func makeUIView(context: Context) -> some UIView {
        imageView.image = selectImage
        imageView.contentMode = .scaleAspectFit
        imageView.addInteraction(interaction)
        return imageView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task {
            if let image = imageView.image {
                let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
                let analysis = try? await analyzer.analyze(image, configuration: configuration)
                if let analysis = analysis {
                    interaction.analysis = analysis
                    interaction.preferredInteractionTypes = .imageSubject
                    objectImage = try await interaction.image(for: interaction.subjects)
                }
            }
        }
    }
}


class LiftImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        .zero
    }
}
