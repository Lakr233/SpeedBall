//
//  ContentView.swift
//  speedball
//
//  Created by 秋星桥 on 5/29/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("ballOffsetX") private var offsetX: Double = 0.5
    @AppStorage("ballOffsetY") private var offsetY: Double = 0.3
    @State var isDragging: Bool = false

    var body: some View {
        GeometryReader { geometry in
            BallView()
                .position(
                    x: geometry.size.width * offsetX,
                    y: geometry.size.height * offsetY
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let minX = 50.0 / geometry.size.width
                            let maxX = (geometry.size.width - 50.0) / geometry.size.width
                            let minY = 50.0 / geometry.size.height
                            let maxY = (geometry.size.height - 50.0) / geometry.size.height

                            offsetX = min(maxX, max(minX, value.location.x / geometry.size.width))
                            offsetY = min(maxY, max(minY, value.location.y / geometry.size.height))
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
        }
    }
}
