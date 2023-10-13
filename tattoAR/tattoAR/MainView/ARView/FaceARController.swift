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

    lazy var leftcheekNode: SCNNode = {
        let scnnode = SCNNode(geometry: SCNPlane(width: 0.05, height: 0.05))
        scnnode.geometry?.firstMaterial?.diffuse.contents = tattooImage
        return scnnode
    }()

    lazy var rightcheekNode: SCNNode = {
        let scnnode = SCNNode(geometry: SCNPlane(width: 0.05, height: 0.05))
        scnnode.geometry?.firstMaterial?.diffuse.contents = tattooImage
        return scnnode
    }()


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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveAlert))
        arScnView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arScnView.session.pause()
    }

    private func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil}
        guard let faceanchor = anchor as? ARFaceAnchor else  {return nil}
        let faceGeomtry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeomtry)
        faceNode.geometry?.firstMaterial?.transparency = 0.0
        faceNode.addChildNode(leftcheekNode)
        faceNode.addChildNode(rightcheekNode)
        return faceNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
          let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        let blendShapes = faceAnchor.blendShapes
        if let cheekLeft = blendShapes[.cheekSquintLeft] as? Float, let cheekRight = blendShapes[.cheekSquintRight] as? Float {
            leftcheekNode.position = SCNVector3(x: -0.05 - cheekLeft * 0.01, y: 0, z: 0)
            rightcheekNode.position = SCNVector3(x: 0.05 + cheekRight * 0.01, y: 0, z: 0)
        }
        faceGeometry.update(from: faceAnchor.geometry)
    }
    @objc private func saveAlert() {
        SaveAlertController.showAlert(in: self, snapshot: view.snapshot ?? UIImage())
    }

}
