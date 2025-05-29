//
//  BallContainerView.swift
//  speedball
//
//  Created by 秋星桥 on 5/29/25.
//

import SwiftUI

struct BallContainerView: View {
    @AppStorage("ballOffsetX") private var offsetX: Double = 0.75
    @AppStorage("ballOffsetY") private var offsetY: Double = 0.75

    @State var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            BallView()
                .contentShape(Rectangle())
                .scaleEffect(isDragging ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isDragging)
                .position(
                    x: geometry.size.width * offsetX,
                    y: geometry.size.height * offsetY
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDragging {
                                let currentCenterX = geometry.size.width * offsetX
                                let currentCenterY = geometry.size.height * offsetY
                                dragOffset = CGSize(
                                    width: value.startLocation.x - currentCenterX,
                                    height: value.startLocation.y - currentCenterY
                                )
                                isDragging = true
                            }

                            let newX = value.location.x - dragOffset.width
                            let newY = value.location.y - dragOffset.height

                            let minX = 50.0 / geometry.size.width
                            let maxX = (geometry.size.width - 50.0) / geometry.size.width
                            let minY = 50.0 / geometry.size.height
                            let maxY = (geometry.size.height - 50.0) / geometry.size.height

                            offsetX = min(maxX, max(minX, newX / geometry.size.width))
                            offsetY = min(maxY, max(minY, newY / geometry.size.height))
                        }
                        .onEnded { _ in
                            isDragging = false
                            dragOffset = .zero
                        }
                )
        }
    }
}
