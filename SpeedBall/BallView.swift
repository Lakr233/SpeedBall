//
//  BallView.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import ColorfulX
import SwiftUI

private let kAnimation: Animation = .spring.speed(1.5)
private let kTotalWidth: CGFloat = 160
private let kContainerHeight: CGFloat = 48
private let kBallSize: CGFloat = 32

struct BallView: View {
    @StateObject var vm = ViewModel.shared
    @State var eaten = true

    var body: some View {
        ZStack {
            switch vm.state {
            case .content:
                content
                    .transition(.opacity.combined(with: .scale(0.95)))
            case .menu:
                MenuContentView(state: $vm.state, eaten: $eaten)
                    .transition(.opacity.combined(with: .scale(0.95)))
            case let .text(str):
                Text(str)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .transition(.opacity.combined(with: .scale(0.95)))
            case .cleaning:
                CleaningAnimationView()
            }
        }
        .frame(width: kTotalWidth, height: kContainerHeight)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    Color.accent.opacity(0.25),
                    lineWidth: 1
                )
        }
        .padding()
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
        .opacity(eaten ? 0 : 1)
        .scaleEffect(eaten ? 0.5 : 1.0)
        .onAppear { eaten = false }
        .animation(kAnimation, value: eaten)
        .animation(kAnimation, value: vm.state.hashValue)
    }

    var content: some View {
        HStack(spacing: 4) {
            memContent
                .offset(x: -4)
            textContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    var memContent: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.15))
                .frame(width: 34, height: 34)
                .offset(x: 1, y: 1)
                .blur(radius: 1)

            ColorfulView(color: vm.color)
                .overlay {
                    Rectangle()
                        .foregroundStyle(.ballCover)
                }
                .clipShape(Circle())
                .frame(width: kBallSize, height: kBallSize)
                .overlay(
                    Circle()
                        .stroke(Color.green.opacity(0.4), lineWidth: 0.5)
                )

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.4),
                            Color.clear,
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 1,
                        endRadius: 8
                    )
                )
                .frame(width: 18, height: 18)
                .offset(x: -4, y: -4)

            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 4, height: 4)
                .offset(x: -6, y: -6)
                .blur(radius: 0.5)

            Text(vm.memText)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .frame(width: kBallSize, height: kBallSize)
        .contentShape(Circle())
        .onTapGesture {
            doMemClean()
        }
    }

    var textContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(vm.cpuText)
                    .lineLimit(1)
                    .monospacedDigit()
                Spacer()
                Button {
                    vm.state = .menu
                } label: {
                    Text(String(888))
                        .hidden()
                        .overlay {
                            Image(systemName: "ellipsis")
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.primary)

            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(
                        Color(
                            red: 223 / 255,
                            green: 68 / 255,
                            blue: 64 / 255
                        )
                    )
                Text(vm.uploadText)
                    .lineLimit(1)
                    .monospacedDigit()
                Spacer(minLength: 0)
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 6, height: 6)
                    .rotationEffect(.degrees(180))
                    .foregroundStyle(
                        Color(
                            red: 63 / 255,
                            green: 140 / 255,
                            blue: 6 / 255
                        )
                    )
                Text(vm.downloadText)
                    .lineLimit(1)
                    .monospacedDigit()
            }
            .minimumScaleFactor(0.75)
            .font(.system(size: 10, weight: .regular))
            .foregroundColor(.secondary)
            Spacer(minLength: 0)
        }
        .frame(height: kBallSize)
    }

    func doMemClean() {
        vm.state = .cleaning

        DispatchQueue.global().async {
            MemoryInfo.clearMem { result in
                let diff = Int64(result.original) - Int64(result.cleared)
                if diff > 0 {
                    let fmt = ByteCountFormatter()
                    let text = fmt.string(fromByteCount: diff)
                    DispatchQueue.main.async {
                        vm.state = .text(String(localized: "Cleaned \(text) of memory."))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vm.state = .content
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        vm.state = .text(String(localized: "Cleaned memory."))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vm.state = .content
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    BallView()
}
