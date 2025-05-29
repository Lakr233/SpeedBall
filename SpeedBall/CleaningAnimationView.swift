//
//  CleaningAnimationView.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import SwiftUI

struct CleaningAnimationView: View {
    @State private var animationStarted = false
    @State private var rockets: [RocketData] = []

    struct RocketData: Identifiable {
        let id: UUID
        var position: CGPoint
        let size: CGFloat
        var rotation: Double
        var opacity: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                ForEach(rockets) { rocket in
                    Text("🚀")
                        .font(.system(size: rocket.size))
                        .rotationEffect(.degrees(rocket.rotation))
                        .position(x: rocket.position.x, y: rocket.position.y)
                        .opacity(rocket.opacity)
                }
            }
            .onAppear {
                startLoopingAnimation(geometry: geometry)
            }
            .onDisappear {
                rockets.removeAll()
            }
        }
    }

    private func startLoopingAnimation(geometry: GeometryProxy) {
        startRocketAnimation(geometry: geometry)
    }

    private func startRocketAnimation(geometry: GeometryProxy) {
        animationStarted = true
        rockets.removeAll()

        let width = geometry.size.width
        let height = geometry.size.height

        for i in 0 ..< 50 {
            let rocket = RocketData(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 20 ... (width - 20)),
                    y: height + CGFloat.random(in: 80 ... 120)
                ),
                size: CGFloat.random(in: 25 ... 60),
                rotation: -45,
                opacity: 1.0
            )
            rockets.append(rocket)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                animateRocket(at: i, moveUp: height)
            }
        }
    }

    private func animateRocket(at index: Int, moveUp: CGFloat) {
        guard index < rockets.count else { return }

        withAnimation(.easeOut(duration: Double.random(in: 2.0 ... 4.0))) {
            rockets[index].position.y = -moveUp
            rockets[index].rotation += Double.random(in: -30 ... 30)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                if index < rockets.count {
                    rockets[index].opacity = 0.0
                }
            }
        }
    }
}
