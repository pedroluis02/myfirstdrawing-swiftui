//
//  ContentView.swift
//  MyFirstDrawing
//
//  Created by Pedro Luis on 2/20/21.
//  Copyright © 2021 Pedro Luis. All rights reserved.
// ref: https://martinmitrevski.com/2019/07/20/developing-drawing-app-with-swiftui/

import SwiftUI
import Foundation

struct DrawingModel {
    var id = UUID()
    var points: [CGPoint] = [CGPoint]()
    var color: Color = Color.black
    var lineWidth: CGFloat = 2
}

struct ContentView: View {
    @State private var currentDrawing: DrawingModel = DrawingModel()
    @State private var drawings: [DrawingModel] = []
    @State private var lineWidth: CGFloat = 2
    @State private var color: Color = Color.black
    
    var body: some View {
        VStack{
            CanvasView(currentDrawing: $currentDrawing, drawings: $drawings, lineWidth: $lineWidth, color: $color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(){
                Button(action: clearAction){Text("Clear")}
                ColorItemView(color: Color.red, onTap: onColorAction)
                ColorItemView(color: Color.green, onTap: onColorAction)
                ColorItemView(color: Color.blue, onTap: onColorAction)
                Slider(value: $lineWidth, in: 1...10, step: 1)
            }.padding()
        }
    }
    
    func clearAction() {
        self.drawings = [DrawingModel]()
    }
    
    func onColorAction(color: Color) {
        self.color = color
    }
}

struct CanvasView : View {
    @Binding var currentDrawing: DrawingModel
    @Binding var drawings: [DrawingModel]
    @Binding var lineWidth: CGFloat
    @Binding var color: Color
    
    @State private var isDrawing: Bool = false
    
    var body: some View {
        ZStack {
            ForEach(self.drawings, id: \.id) { drawing in
                Path { path in
                    self.add(drawing: drawing, toPath: &path)
                }.stroke(drawing.color, lineWidth: drawing.lineWidth)
            }
            GeometryReader { geometry in
                Path { path in
                    self.add(drawing: self.currentDrawing, toPath: &path)
                }.stroke(self.color, lineWidth: self.lineWidth)
                    .background(Color(white: 0.95))
                    .opacity(self.isDrawing ? 0.8 : 0.01)
                    .gesture(
                        DragGesture(minimumDistance: 0.1)
                            .onChanged({ (value) in
                                self.isDrawing = true
                                let currentPoint = value.location
                                if currentPoint.y >= 0
                                    && currentPoint.y < geometry.size.height {
                                    self.currentDrawing.points.append(currentPoint)
                                }
                            })
                            .onEnded({ (value) in
                                self.currentDrawing.color = self.color
                                self.currentDrawing.lineWidth = self.lineWidth
                                self.drawings.append(self.currentDrawing)
                                
                                self.currentDrawing = DrawingModel()
                                
                                self.isDrawing = false
                            })
                )
            }
        }
    }
    
    private func add(drawing: DrawingModel, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            for i in 0..<(points.count - 1) {
                let current = points[i]
                let next = points[i + 1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
    }
}

struct ColorItemView : View {
    var width: CGFloat = 48
    var height: CGFloat = 48
    var color: Color =  Color.blue
    var onTap: ((_ c1: Color) -> Void)? = nil
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: width, height: height).onTapGesture {
                self.onTap?(self.color)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
