//
//  MemoryInfo.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import Darwin
import Foundation
import IOKit.ps

enum MemoryInfo {
    static func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        precondition(result == KERN_SUCCESS)
        return UInt64(info.resident_size)
    }

    static func getCurrentMemoryUsagePercent() -> Double {
        var info = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        precondition(result == KERN_SUCCESS)

        let totalPages = info.free_count + info.active_count + info.inactive_count + info.wire_count
        let usedPages = info.active_count + info.wire_count

        return Double(usedPages) / Double(totalPages)
    }

    typealias MemClearResult = (original: UInt64, cleared: UInt64)

    static var isCleaning = NSLock()
    static func clearMem(chunksize: Int = 4096, _ completion: @escaping (MemClearResult) -> Void) {
        guard isCleaning.try() else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            defer { isCleaning.unlock() }

            let originalMemory = getCurrentMemoryUsage()

            var isMemoryWarningReceived = false
            let memWarning = DispatchSource.makeMemoryPressureSource(
                eventMask: [.warning],
                queue: .main
            )
            memWarning.setEventHandler { isMemoryWarningReceived = true }
            memWarning.resume()

            let maxSize = Double(ProcessInfo.processInfo.physicalMemory)
            var maxIter = Int(maxSize / Double(chunksize)) + 1

            autoreleasepool {
                var memoryBlocks: [UnsafeMutableRawPointer] = []
                while !isMemoryWarningReceived, maxIter > 0 {
                    maxIter -= 1
                    let mem = malloc(chunksize)
                    if let mem {
                        bzero(mem, chunksize)
                        memoryBlocks.append(mem)
                    } else {
                        break
                    }
                }
                Thread.sleep(forTimeInterval: 3)
                memoryBlocks.forEach { free($0) }
                memoryBlocks.removeAll()
            }

            autoreleasepool {}
            Thread.sleep(forTimeInterval: 3)
            autoreleasepool {}

            let clearedMemory = getCurrentMemoryUsage()

            DispatchQueue.main.async {
                completion((original: originalMemory, cleared: clearedMemory))
            }
        }
    }
}
