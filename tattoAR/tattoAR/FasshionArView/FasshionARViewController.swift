//
//  FasshionARViewController.swift
//  tattoAR
//
//  Created by 235 on 11/6/23.
//

import ARKit
import SceneKit
import UIKit
import SceneKit.ModelIO
import SwiftUI

class FasshionARViewController: UIViewController, ARSCNViewDelegate {
    private var arSCNView: ARSCNView!
    var clothesImage: UIImage
//    lazy var clothesNode: SCNNode = {
//        let scnNode = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.3))
//        scnNode.geometry?.firstMaterial?.diffuse.contents = clothesImage
//        return scnNode
//    }()

    init(clothesImage: UIImage) {
        self.clothesImage = clothesImage
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        arSCNView = ARSCNView(frame: view.bounds)
        view.addSubview(arSCNView)
        let configuartion = ARWorldTrackingConfiguration()
        configuartion.planeDetection = [.horizontal, .vertical]
        arSCNView.session.run(configuartion, options: [.resetTracking, .removeExistingAnchors])
        arSCNView.delegate = self
        arSCNView.scene = SCNScene()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchTap(_ :)))
        arSCNView.addGestureRecognizer(tapGestureRecognizer)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSCNView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = MTLCreateSystemDefaultDevice() else {return nil}
        let horizontalGeomtry = ARSCNPlaneGeometry(device: device)
        let horizontalNode = SCNNode(geometry: horizontalGeomtry)
        horizontalNode.geometry?.firstMaterial?.transparency = 0.0
//        horizontalNode.addChildNode(clothesNode)
        return horizontalNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor, let geometry = node.geometry as? ARSCNPlaneGeometry else {
            return
        }
//        clothesNode.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)

        geometry.update(from: anchor.geometry)
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let touchLocation = touch.location(in: arSCNView)
//            clothesNode.position = SCNVector3(x: Float(touchLocation.x), y: Float(touchLocation.y), z:0)
//            print(touch)
//            print(touchLocation)
//        }
//    }

    @objc func searchTap(_ sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        guard let urlPath = Bundle.main.url(forResource: "person", withExtension: "usdz") else {return}
        let asset = MDLAsset(url: urlPath)
        asset.loadTextures()
        
        if let hitResult = hitTest.first {
            let postion = hitResult.worldTransform.columns.3
            let scnNode = SCNNode(mdlObject: asset.object(at: 6))
            let clotheNode = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.2))
            scnNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            if let rotate = arSCNView.session.currentFrame?.camera {
                clotheNode.eulerAngles.y = rotate.eulerAngles.y
                scnNode.eulerAngles.y = rotate.eulerAngles.y
            }
            scnNode.scale = SCNVector3(0.04, 0.06, 0.05)
            scnNode.position = SCNVector3(x: postion.x, y: postion.y  , z: postion.z - 0.03)
            scnNode.geometry?.firstMaterial?.diffuse.contents =  Color.skinColor
            let material = SCNMaterial()
            material.diffuse.contents = clothesImage
            clotheNode.geometry?.firstMaterial = material
            clotheNode.position = SCNVector3(x: postion.x, y: postion.y + 0.15 , z: postion.z + 0.02)
            arSCNView.scene.rootNode.addChildNode(scnNode)
            arSCNView.scene.rootNode.addChildNode(clotheNode)
            print(hitTest)
        }
    }
}
