//
//  InputImageViewModel.swift
//  tattoAR
//
//  Created by 235 on 2023/09/10.
//

import SwiftUI
import PhotosUI
import VisionKit
@MainActor
class InputImageViewModel: ObservableObject {
    @Published private(set) var imageView = LiftImageView()
    @Published private(set) var objectImage : UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else{return}
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                imageView.image = uiImage
                imageView.addInteraction(interaction)
                try await analyzeImage()
            } catch {
                print(error)
            }
        }
    }
    private func analyzeImage() async throws {
        Task{
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

