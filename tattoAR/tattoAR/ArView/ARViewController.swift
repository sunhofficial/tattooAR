//
//  ARViewController.swift
//  tattoAR
//
//  Created by 235 on 2023/09/29.
//

import UIKit
import CoreML
import ARKit
enum HandPose {
    case rightRock
    case leftRock
    case background
}
final class ARViewController: UIViewController {
    var arScnView: ARSCNView!
    private var frameCounter: Int = 0 //매프레임마다 손모양 인식이 아니라 일정한 간격으로 수행하면 좀 더 부드러워짐
    private let handPosePredictionInterval: Int = 30 //30frame마다
    var tatooImage: UIImage
    var blackPoint: Double = 0.0
    private var handPose: HandPose = .background
    private var model = try? HandModel(configuration: MLModelConfiguration())
    override func viewDidLoad() {
        super.viewDidLoad()
        arScnView = ARSCNView(frame: view.bounds)
        view.addSubview(arScnView)
        arScnView.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        arScnView.session.run(configuration)

    }
    init(tatooImage: UIImage, blackPoint: Double) {
        self.tatooImage = tatooImage
        self.blackPoint = blackPoint
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("HandPoseRequest failed: \(error)")
        }
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {return}

        guard let handObservation = handPoses.first else {return}
        frameCounter += 1
        if frameCounter % handPosePredictionInterval == 0 {
            frameCounter = 0
            makePrediction(handPoseObservation: handObservation)
        }
    }
    func makePrediction(handPoseObservation: VNHumanHandPoseObservation) {
        guard let keypointsMultiArray = try? handPoseObservation.keypointsMultiArray() else { fatalError()}
        do {
            let handPrediction = try model!.prediction(poses: keypointsMultiArray)
            let label = handPrediction.label
            guard let confidence = handPrediction.labelProbabilities[label] else {return}
            if confidence > 0.8 {
                switch label {
                case "rightRock":
                    handPose = .rightRock
                case "leftRock":
                    handPose = .leftRock
                default:
                    handPose = .background
                    break
                }
            }
        } catch {
            print("PREDICTION ERRRRRROR")
        }
    }
}
