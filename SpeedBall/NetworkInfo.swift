//
//  NetworkInfo.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/30/25.
//

import Foundation

struct NetworkInfo {
    static var shared = NetworkInfo()

    private init() {}

    private var lastUploadBytes: UInt64 = 0
    private var lastUploadTime: Date = .init()
    private var lastDownloadBytes: UInt64 = 0
    private var lastDownloadTime: Date = .init()

    mutating func updateNetworkUsage() -> (uploadPerSec: Int, downloadPerSec: Int) {
        var ifaddrs: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddrs) == 0 else { return (0, 0) }
        defer { freeifaddrs(ifaddrs) }

        var totalUpload: UInt64 = 0
        var totalDownload: UInt64 = 0

        var current = ifaddrs
        while current != nil {
            defer { current = current?.pointee.ifa_next }

            guard let addr = current?.pointee.ifa_addr,
                  addr.pointee.sa_family == UInt8(AF_LINK) else { continue }

            let stats = current?.pointee.ifa_data?.assumingMemoryBound(to: if_data.self)

            if let stats {
                totalUpload += UInt64(stats.pointee.ifi_obytes)
                totalDownload += UInt64(stats.pointee.ifi_ibytes)
            }
        }

        let now = Date()
        let uploadPerSec = calculateRate(
            currentBytes: totalUpload,
            lastBytes: &lastUploadBytes,
            lastTime: &lastUploadTime,
            currentTime: now
        )
        let downloadPerSec = calculateRate(
            currentBytes: totalDownload,
            lastBytes: &lastDownloadBytes,
            lastTime: &lastDownloadTime,
            currentTime: now
        )
        return (uploadPerSec, downloadPerSec)
    }

    func calculateRate(
        currentBytes: UInt64,
        lastBytes: inout UInt64,
        lastTime: inout Date,
        currentTime: Date
    ) -> Int {
        let elapsed = currentTime.timeIntervalSince(lastTime)
        guard elapsed > 0 else { return 0 }

        let bytesDiff = currentBytes - lastBytes
        lastBytes = currentBytes
        lastTime = currentTime

        return Int(Double(bytesDiff) / elapsed)
    }
}
