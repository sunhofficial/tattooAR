//
//  RemoveBackground.swift
//  tattoAR
//
//  Created by 235 on 2023/09/07.
//
import CoreML
import SwiftUI
import Vision

class RemoveBackground: ObservableObject {
    private let model = try! VNCoreMLModel(for: DeepLabV3(configuration: MLModelConfiguration()).model)
    var inputImage: UIImage = UIImage()
    @Published var outputImage: UIImage?

    func segmentImage() {
        let ciImage = CIImage(image: inputImage)!
        var request: VNCoreMLRequest
        request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete )
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print("Faile to perform Segmentation\(error.localizedDescription)")
            }
        }

    }
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationMap = observations.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationMap.image(min: 0, max: 1)
                self.outputImage = segmentationMask!.resized(to: self.inputImage.size)
                self.outputImage = self.maskInputImage()
            }
        }
    }

    func maskInputImage() -> UIImage {
        let bgImage = UIImage.imageFromColor(color: .blue, size: self.inputImage.size, scale: self.inputImage.scale)!
        let beginImage = CIImage(cgImage: inputImage.cgImage!)
        let background = CIImage(cgImage: bgImage.cgImage!)
        let mask = CIImage(cgImage: (self.outputImage?.cgImage!)!)
        if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: beginImage,
            kCIInputBackgroundImageKey: background,
            kCIInputMaskImageKey: mask])?.outputImage {
            let ciContext = CIContext(options: nil)
            let filteredImageReference = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
            return UIImage(cgImage: filteredImageReference!)
        }
        return UIImage()
    }
}
extension UIImage {
    class func imageFromColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1),scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image

    }
}
