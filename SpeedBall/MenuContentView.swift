//
//  MenuContentView.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import SwiftUI

struct MenuContentView: View {
    @Binding var state: ViewState
    @Binding var eaten: Bool

    var major: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }

    var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }

    var versionText: LocalizedStringKey {
        "Version: \(major).\(build)"
    }

    var body: some View {
        HStack {
            Spacer(minLength: 0)

            Button {
                state = .content
            } label: {
                Image(systemName: "arrow.left")
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(versionText)

            Spacer(minLength: 0)

            Button {
                eaten = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    exit(0)
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .fontDesign(.rounded)
    }
}
