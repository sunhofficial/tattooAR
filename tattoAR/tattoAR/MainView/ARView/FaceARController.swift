//
//  FaceARController.swift
//  tattoAR
//
//  Created by 235 on 10/9/23.
//

import ARKit
import UIKit

class FaceARController: UIViewController, ARSCNViewDelegate {
    private var arScnView: ARSCNView!
    var tattooImage: UIImage
    private var trackedNode: SCNNode?
    
    init(tattooImage: UIImage) {
        self.tattooImage = tattooImage
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arScnView = ARSCNView(frame: view.bounds)
        view.addSubview(arScnView)
        let configuartion = ARFaceTrackingConfiguration()
        arScnView.session.run(configuartion,  options: [.resetTracking, .removeExistingAnchors])
        arScnView.delegate = self
        arScnView.scene = SCNScene()
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
           guard let faceAnchor = arScnView.session.currentFrame?.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else {
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
        planeGeomtry.firstMaterial?.diffuse.contents = tattooImage
        imageNode.geometry = planeGeomtry
          let position3D = simd_float3(position.x, position.y, position.z)
        if let position = trackedNode?.simdWorldPosition {
                 imageNode.simdPosition = position
             }
        arScnView.scene.rootNode.addChildNode(imageNode)
    }
}
