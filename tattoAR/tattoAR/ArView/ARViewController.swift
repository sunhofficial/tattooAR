//
//  ARViewController.swift
//  tattoAR
//
//  Created by 235 on 2023/09/29.
//

import UIKit
import CoreML
import AVFoundation
import ARKit

enum HandPose {
    case rightRock
    case leftRock
    case background
}
final class ARViewController: UIViewController {
    var arScnView: ARSCNView!
    private var frameCounter: Int = 0 //매프레임마다 손모양 인식이 아니라 일정한 간격으로 수행하면 좀 더 부드러워짐
    private let handPosePredictionInterval: Int = 100 //100frame마다
    var tatooImage: UIImage

    //    private var handPose: HandPose = .background
    private var tattoImageView: UIImageView
    private var frameSize: Double = 0.0
    private var model = try? HandModel(configuration: MLModelConfiguration())
    var x: Double = 0
    var y: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        arScnView = ARSCNView(frame: view.bounds)
        view.addSubview(arScnView)
        arScnView.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        arScnView.session.run(configuration)
        arScnView.addSubview(tattoImageView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveImage))
        arScnView.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func saveImage() {
        UIImageWriteToSavedPhotosAlbum(self.view.snapshot!, nil, nil, nil)
    }
    init(tatooImage: UIImage) {
        self.tatooImage = tatooImage
        self.tattoImageView = UIImageView(image: tatooImage)
        tattoImageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
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
            let handPose = makePrediction(handPoseObservation: handObservation)
            if handPose != .background {
                let tattoPoint = findTatooSpot(handPoseObservation: handObservation)
                tattoImageView.frame =  CGRect(x: tattoPoint.x, y: tattoPoint.y , width: frameSize, height: frameSize)
            }
            else {
                tattoImageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            }
        }
    }

    func findTatooSpot(handPoseObservation: VNHumanHandPoseObservation) -> CGPoint {
        guard let wristSpot = try? handPoseObservation.recognizedPoint(.wrist) else{ return CGPoint.zero}
        guard let ringSpot = try? handPoseObservation.recognizedPoint(.ringMCP) else {return CGPoint.zero}
        guard let middleSpot = try? handPoseObservation.recognizedPoint(.middleMCP) else {return CGPoint.zero}
        let ringMiddleHalfSpotX = (ringSpot.location.x + middleSpot.location.x) / 2
        let ringMiddleHalfSpotY = (ringSpot.location.y + middleSpot.location.y) / 2
        let distanceY = wristSpot.location.y - ringMiddleHalfSpotY
        let distanceX = wristSpot.location.x - ringMiddleHalfSpotX
        let inclination = distanceY/distanceX
        let distance = sqrt(pow(distanceX, 2) + pow(distanceY, 2))
        let newX = sqrt(distance / (inclination * inclination + 1) ) + wristSpot.location.x
        let newY = wristSpot.location.y + inclination * sqrt(distance / (inclination * inclination + 1))
        frameSize = distanceX * 500
        return CGPoint(x:newY * UIScreen.main.bounds.width, y: newX * UIScreen.main.bounds.height)
    }

    func makePrediction(handPoseObservation: VNHumanHandPoseObservation) -> HandPose {
        guard let keypointsMultiArray = try? handPoseObservation.keypointsMultiArray() else { fatalError()}
        do {
            let handPrediction = try model!.prediction(poses: keypointsMultiArray)
            let label = handPrediction.label
            guard let confidence = handPrediction.labelProbabilities[label] else {return .background}
            if confidence > 0.9 {
                switch label {
                case "rightRock":
                    return .rightRock
                    //                    handPose = .rightRock
                case "leftRock":
                    //                    handPose = .leftRock
                    return .leftRock
                default:
                    //                    handPose = .background
                    return .background
                }
            }
        } catch {
            print("PREDICTION ERRRRRROR")
        }
        return .background
    }
}

