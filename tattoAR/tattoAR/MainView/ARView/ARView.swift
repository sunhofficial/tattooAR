import SwiftUI
import ARKit
struct ARView: View {
    @ObservedObject var arDeleagte = ARDelegate()
    var body: some View {
        ZStack{
            ARViewRepresentable(arDelegate: arDeleagte)
        }
    }
}
