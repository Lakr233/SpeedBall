//
//  ViewModel.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import ColorfulX
import Combine
import Darwin
import Foundation
import SwiftUI

enum ViewState: Codable, Hashable {
    case content
    case menu
    case text(String)
    case cleaning
}

class ViewModel: ObservableObject {
    static let shared = ViewModel()
    private var timer: Timer!

    private init() {
        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateSystemInfoTikSec()
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    deinit {
        timer.invalidate()
        timer = nil
    }

    @Published var state: ViewState = .content

    @Published var cpuPercent: Double = 0
    @Published var memPercent: Double = 0
    @Published var netUpload: Int = 0
    @Published var netDownload: Int = 0

    let byteCountFormat: ByteCountFormatter = {
        let fmt = ByteCountFormatter()
        fmt.allowedUnits = [.useAll]
        fmt.countStyle = .binary
        return fmt
    }()

    var memIsHigh: Bool {
        memPercent > 0.9
    }

    var color: ColorfulPreset {
        memIsHigh ? .sunset : .ocean
    }

    var cpuText: String {
        "CPU \(Int(cpuPercent * 100))%"
    }

    var memText: String {
        "\(Int(memPercent * 100))%"
    }

    var uploadText: String {
        if netUpload <= 0 {
            "0 K/s"
        } else {
            byteCountFormat.string(fromByteCount: .init(netUpload))
        }
    }

    var downloadText: String {
        if netDownload <= 0 {
            "0 K/s"
        } else {
            byteCountFormat.string(fromByteCount: .init(netDownload))
        }
    }

    private func updateSystemInfoTikSec() {
        let cpu = CentralProcessorInfo.shared.calculateCurrentLoadPercent()
        let mem = MemoryInfo.getCurrentMemoryUsagePercent()
        let net = NetworkInfo.shared.updateNetworkUsage()
        DispatchQueue.main.async {
            self.cpuPercent = cpu
            self.memPercent = mem
            self.netUpload = net.uploadPerSec
            self.netDownload = net.downloadPerSec
        }
    }
}
