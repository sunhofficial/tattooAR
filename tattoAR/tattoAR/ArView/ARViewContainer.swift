//
//  ArViewContainer.swift
//  tattoAR
//
//  Created by 235 on 2023/09/29.
//

import SwiftUI
import RealityKit
import VisionKit
struct ARViewContainer: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController
    var tatooImage: UIImage

    func makeUIViewController(context: Context) -> ARViewController {
        let viewController = ARViewController(tatooImage: tatooImage)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
}

