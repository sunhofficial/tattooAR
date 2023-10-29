//
//  CustomImagePicker.swift
//  tattoAR
//
//  Created by 235 on 10/28/23.
//

import SwiftUI
import PhotosUI
extension View {

    @ViewBuilder
    func cropImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?> ) ->some View {
        CustomImagePicker(show: show, croppedImage: croppedImage) {
            self
        }
    }

    @ViewBuilder
    func frame(_ size: CGSize)-> some View {
        self.frame(width: size.width, height: size.height)
    }

    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

fileprivate struct CustomImagePicker<Content: View>: View {
    var content: Content
    @Binding var show: Bool
    @Binding var croppedImage: UIImage?
    //MARK: View Properties
    @State private var photosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCropView: Bool = false
    init(show: Binding<Bool>, croppedImage: Binding<UIImage?>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
    }



    var body: some View {
        content
            .photosPicker(isPresented: $show, selection: $photosItem)
            .onChange(of: photosItem) { oldValue, newValue in
                if let newValue {
                    Task {
                        if let imageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                            await MainActor.run {
                                selectedImage = image
                                showCropView = true
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCropView) {
                //dismiss될때
                selectedImage = nil
                showCropView = false
            } content: {
                CropView(image: selectedImage) { croppedImage, status in
                    if let croppedImage {
                        self.croppedImage = croppedImage
                    }
                }
            }
    }
}

struct CropView: View {
    var image: UIImage?
    var onCrop: (UIImage?, Bool) -> ()
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offSet: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false



    var body: some View {
        NavigationStack {
            ImageView()
                .navigationTitle("이미지 편집하기")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.black
                        .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            //converting view to image
                            let render = ImageRenderer(content: ImageView(true))
                            //                        render.proposedSize = .init(<#T##size: CGSize##CGSize#>)
                            if let image = render.uiImage {
                                onCrop(image, true)
                            } else {
                                onCrop(nil, false)
                            }
                            dismiss()

                        } label: {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
        }
    }

    @ViewBuilder
    func ImageView(_ hideGrids: Bool = false) -> some View {
        GeometryReader {
            let size = $0.size
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(size)
                    .overlay {
                        GeometryReader {proxy in
                            let rect = proxy.frame(in: .named("CROPVIEW"))
                            Color.clear
                                .onChange(of: isInteracting) { oldValue, newValue in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if rect.minX > 0 {
                                            offSet.width = (offSet.width - rect.minX)
                                            haptics(.medium)
                                        }
                                        if rect.minY > 0 {
                                            offSet.height = (offSet.height - rect.minY)
                                            haptics(.medium)

                                        }
                                        if rect.maxX < size.width {
                                            offSet.width = (rect.minX - offSet.width)
                                            haptics(.medium)

                                        }
                                        if rect.maxY < size.height {
                                            offSet.height = (rect.minY - offSet.height)
                                            haptics(.medium)

                                        }
                                    }

                                    // true면 드래그중이고 false면 멈춰있음
                                    if !newValue {
                                        lastStoredOffset = offSet
                                    }
                                }
                        }
                    }
                    .onChange(of: isInteracting) { oldValue, newValue in
                        if !newValue {
                            lastStoredOffset = offSet
                        }
                    }
            }
        }
        .scaleEffect(scale)
        .offset(offSet)
        .overlay {
            if !hideGrids {
                Grids()
            }
        }
        .coordinateSpace(.named("CROPVIEW"))
        .gesture(
            DragGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let translation = value.translation
                    offSet = CGSize(width: translation.width + lastStoredOffset.width, height: translation.height + lastStoredOffset.height)
                })
                .onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            lastScale = scale - 1
                        }
                    }
                })

        )
        .gesture(
            MagnifyGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                })
                .onChanged({value in
                    let updateScale = value.magnification + lastScale
                    scale  = updateScale < 1 ? 1 : updateScale})
        )
        .frame(width: 300, height: 400)
    }

    @ViewBuilder
    func Grids() -> some View {
        ZStack {
            HStack {
                ForEach(1...5, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack {
                ForEach(1...8, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}
