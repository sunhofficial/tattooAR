//
//  InputImageView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/08.
//

import SwiftUI
import PhotosUI
struct InputImageView: View {
    @ObservedObject var vm = InputImageViewModel()
    @State private var isFullScreenCoverPresented = false
    @State private var sliderValue = 0.0
    @State private var isBlackToggle = false
    @State private var handtattooMode = true
    var body: some View {
        NavigationStack {
            ZStack{
                Color.backGround
                VStack {
                    HStack{
                        Spacer()
                        ColorToBlackBtn
                    }
                    .padding(.bottom,8)
                    PhotoPikerView
                        .aspectRatio(CGSize(width: 1, height: 1.33), contentMode: .fit)
                    ModeChoiceBtn
                        .padding(.vertical, 16)
                    NavigationBtn
                        .padding(.horizontal, 10)
                }
                .padding(.top,72)
                .padding(.horizontal,16)
            }
            .ignoresSafeArea()
        }
    }
}
extension InputImageView {
    var ColorToBlackBtn: some View {
        Button {
            isBlackToggle.toggle()
        } label: {
            Circle()
                .fill(isBlackToggle ? AngularGradient(gradient: Gradient(colors: [.red,.orange,.yellow,.green,.blue,.purple,.red]),center: .center) : AngularGradient(gradient: Gradient(colors: [.black]), center: .center))
                .frame(width: 32,height: 32)
        }
    }

    var PhotoPikerView: some View {
        PhotosPicker(selection: $vm.imageSelection, matching: .images) {
            Rectangle()
                .fill(vm.objectImage != nil ? Color.white : Color.photoBackGround)
                .overlay(
                    Group{
                        if let objectImage = vm.objectImage {
                            Image(uiImage: objectImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else{
                            VStack{
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .foregroundStyle(Color.photoFontColor)
                                    .frame(width: 40,height: 40)
                                    .padding(.bottom,10)
                                Text("Click here to add an Image")
                                    .font(.body)
                                    .foregroundStyle(Color.photoFontColor)

                            }
                        }

                    }
                )
        }
    }
    var ModeChoiceBtn: some View {
        HStack(spacing: 40){
            Image("Arm")
                .resizable()
                .clipShape(Circle())
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(handtattooMode ? Color.mainColor : Color.black))
                .opacity(handtattooMode ? 1 : 0.1)
                .onTapGesture {
                    handtattooMode = true
                }

            Image("FaceCamera")
                .resizable()
                .clipShape(Circle())
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(handtattooMode ?  Color.black : Color.mainColor))
                .opacity(handtattooMode ? 0.1 : 1)
                .onTapGesture {
                    handtattooMode = false
                }
        }
    }

    var NavigationBtn: some View {
        NavigationLink(destination: TatooView(tatooImage: vm.applySketchEffect(to: vm.objectImage ?? UIImage()))) {
            HStack {
                Label("타투하기", systemImage: "paintbrush")
                    .foregroundStyle(Color.mainColor)
                    .font(.system(size: 24, weight: .medium))
                    .blur(radius: 8.0)
                    .overlay {
                        Label("타투하기", systemImage: "paintbrush")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 24, weight: .medium))
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                    .stroke(Color.mainColor,lineWidth: 4)
                    .blur(radius: 4)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20,style: .continuous)
                    .fill(.clear)
                    .stroke(Color.mainColor, lineWidth: 2)
                    .blur(radius: 0.52)
            }
            .overlay{
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                    .stroke(Color.white, lineWidth: 1)
                    .blur(radius: 0.35)
            }

        }
    }
}

struct InputImageView_Previews: PreviewProvider {
    static var previews: some View {
        InputImageView()
    }
}
