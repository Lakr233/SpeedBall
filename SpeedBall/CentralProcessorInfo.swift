//
//  CentralProcessorInfo.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import Darwin
import Foundation

struct CentralProcessorInfo {
    static var shared = CentralProcessorInfo()

    private init() {
        _ = calculateCurrentLoad()
    }

    var previous: host_cpu_load_info = .init()

    mutating func calculateCurrentLoadPercent() -> Double {
        let diff = calculateCurrentLoad()
        return diff.system + diff.user
    }

    mutating func calculateCurrentLoad() -> (system: Double, user: Double, idle: Double, nice: Double) {
        let stats = Self.hostProcessLoadInfo()

        let userDiff = stats.cpu_ticks.0 - previous.cpu_ticks.0
        let systemDiff = stats.cpu_ticks.1 - previous.cpu_ticks.1
        let idleDiff = stats.cpu_ticks.2 - previous.cpu_ticks.2
        let niceDiff = stats.cpu_ticks.3 - previous.cpu_ticks.3

        let totalTicks = systemDiff + userDiff + idleDiff + niceDiff

        let system = Double(systemDiff) / Double(totalTicks)
        let user = Double(userDiff) / Double(totalTicks)
        let idle = Double(idleDiff) / Double(totalTicks)
        let nice = Double(niceDiff) / Double(totalTicks)

        previous = stats

        return (system, user, idle, nice)
    }

    static func hostProcessLoadInfo() -> host_cpu_load_info {
        var info = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info>.stride
                / MemoryLayout<integer_t>.stride
        )

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            host_statistics(
                mach_host_self(),
                HOST_CPU_LOAD_INFO,
                $0.withMemoryRebound(
                    to: integer_t.self,
                    capacity: 1
                ) { $0 },
                &count
            )
        }

        guard kerr == KERN_SUCCESS else {
            assertionFailure()
            return host_cpu_load_info()
        }
        return info
    }
}
