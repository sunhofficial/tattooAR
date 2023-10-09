//
//  ARDelgeate.swift
//  SwiftUIARKit
//
//  Created by Gualtiero Frigerio on 18/05/21.
//

import Foundation
import ARKit
import UIKit

class ARDelegate: NSObject, ARSCNViewDelegate, ObservableObject {
    @Published var message:String = "starting AR"
    private var arView: ARSCNView?
    private var circles:[SCNNode] = []
    private var trackedNode:SCNNode?
    var tatooImage: UIImage?

    func setARView(_ arView: ARSCNView) {
        self.arView = arView
        guard ARFaceTrackingConfiguration.isSupported else  {return}
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        arView.delegate = self
        arView.scene = SCNScene()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnARView))
        arView.addGestureRecognizer(tapGesture)

    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
           guard let arView = arView,
                 let faceAnchor = arView.session.currentFrame?.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else {
               return
           }

           // Face Anchor의 Transform으로 볼의 위치를 설정
           let ballPosition = faceAnchor.transform.columns.3
           trackedNode?.simdTransform = faceAnchor.transform

           // 볼에 점을 찍어주는 함수 호출
           addPointToBall(position: ballPosition)
       }
    private func addPointToBall(position: simd_float4) {
        let imageNode = SCNNode()
        let planeGeomtry = SCNPlane(width: 0.1, height: 0.1)
        planeGeomtry.firstMaterial?.diffuse.contents = tatooImage
        imageNode.geometry = planeGeomtry
          let position3D = simd_float3(position.x, position.y, position.z)
        if let position = trackedNode?.simdWorldPosition {
                 imageNode.simdPosition = position
             }
        arView!.scene.rootNode.addChildNode(imageNode)
    }
    @objc func tapOnARView(sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = sender.location(in: arView)
        if let node = nodeAtLocation(location) {
            removeCircle(node: node)
        }
        else if let result = raycastResult(fromLocation: location) {
            addCircle(raycastResult: result)
        }
    }

//    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//        print("camera did change \(camera.trackingState)")
//        switch camera.trackingState {
//        case .limited(_):
//            message = "tracking limited"
//        case .normal:
//            message =  "tracking ready"
//        case .notAvailable:
//            message = "cannot track"
//        }
//    }

    // MARK: - Private



    private func addCircle(raycastResult: ARRaycastResult) {
        let circleNode = createCircle(fromRaycastResult: raycastResult)
        if circles.count >= 2 {
            for circle in circles {
                circle.removeFromParentNode()
            }
            circles.removeAll()
        }

        arView?.scene.rootNode.addChildNode(circleNode)
        circles.append(circleNode)


    }

    private func nodeAtLocation(_ location:CGPoint) -> SCNNode? {
        guard let arView = arView else { return nil }
        let result = arView.hitTest(location, options: nil)
        return result.first?.node
    }



    private func raycastResult(fromLocation location: CGPoint) -> ARRaycastResult? {
        guard let arView = arView,
              let query = arView.raycastQuery(from: location,
                                        allowing: .existingPlaneGeometry,
                                        alignment: .horizontal) else { return nil }
        let results = arView.session.raycast(query)
        return results.first
    }

    func removeCircle(node:SCNNode) {
        node.removeFromParentNode()
        circles.removeAll(where: { $0 == node })
    }
     func createCircle(fromRaycastResult result:ARRaycastResult) -> SCNNode {
        let circleGeometry = SCNSphere(radius: 0.010)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue

        circleGeometry.materials = [material]

        let circleNode = SCNNode(geometry: circleGeometry)
        circleNode.simdWorldTransform = result.worldTransform

        return circleNode
    }
}

