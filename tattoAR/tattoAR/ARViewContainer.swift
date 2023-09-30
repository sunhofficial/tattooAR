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
    func makeUIViewController(context: Context) -> ARViewController {
        let viewController = ARViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ARViewController
//    var pointsProcessorHandler: (([CGPoint]) -> Void)?
}

