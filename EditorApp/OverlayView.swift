//
//  OverlayView.swift
//  EditorApp
//
//  Created by satoutakeshi on 2019/11/29.
//  Copyright © 2019 satoutakeshi. All rights reserved.
//

import SwiftUI

enum DrawType {
    case red
    case clear

    var color: Color {
        switch self {
            case .red:
                return Color.red
            case .clear:
                return Color.white
        }
    }
}

struct DrawData {
    var dragPoints: [DrawPoints]
}

struct DrawPoints: Identifiable {
    var points: [CGPoint]
    var color: Color
    var id = UUID()
}

final class DrawViewModel: ObservableObject {
    @Published var drawData: DrawData
    init(drawData: DrawData) {
        self.drawData = drawData
    }
    func screenShot(size: CGSize) {
        let rootView = UIApplication.shared.windows.first!
        let screenshot = rootView.screenShot(size: size)
        print(screenshot)
    }
}

let tmpData = DrawData(dragPoints: [])

struct DrawPathView: View {

    @ObservedObject var viewModel: DrawViewModel

    var body: some View {
        ZStack {
            ForEach(viewModel.drawData.dragPoints) { data in
                Path { path in
                    path.addLines(data.points)
                }
                .stroke(data.color, lineWidth: 10)
            }
        }
    }
}

struct OverlayView: View {
    @State var tmpDrawPoints: DrawPoints = DrawPoints(points: [], color: .red)
    @State var viewModel: DrawViewModel = DrawViewModel(drawData: DrawData(dragPoints: []))
    @State var startPoint: CGPoint = CGPoint.zero
    @State var selectedColor: DrawType = .red
    @State var canvasSize: CGSize = .zero
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 300, alignment: .center)

                    .overlay(

                        DrawPathView(viewModel: self.viewModel)
                            .overlay(
                                // ドラッグ中の描画。指を離したらここの描画は消えるがDrawPathViewが上書きするので見た目は問題ない
                                Path { path in
                                    path.addLines(self.tmpDrawPoints.points)

                                }
                                .stroke(self.tmpDrawPoints.color, lineWidth: 10)
                        )
                )
                    .gesture(
                        DragGesture()
                            .onChanged({ (value) in

                                if self.startPoint != value.startLocation {
                                    self.tmpDrawPoints.points.append(value.location)
                                    self.tmpDrawPoints.color = self.selectedColor.color

                                }
                            })
                            .onEnded({ (value) in
                                self.startPoint = value.startLocation
                                self.viewModel.drawData.dragPoints.append(self.tmpDrawPoints)
                                self.tmpDrawPoints = DrawPoints(points: [], color: self.selectedColor.color)
                            })
                )
                VStack(spacing: 10) {
                    Button(action: {
                        self.selectedColor = .red

                    }) { Text("赤")
                    }
                    Button(action: {
                        self.selectedColor = .clear
                    }) { Text("消しゴム")
                    }
                    Button(action: {
                        self.viewModel.screenShot(size: geometry.frame(in: .global).size)
                    }) { Text("保存")
                    }
                    Spacer()

                }
                .frame(minWidth: 0.0, maxWidth: CGFloat.infinity)
                .background(Color.gray)
            }

        }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView()
    }
}
