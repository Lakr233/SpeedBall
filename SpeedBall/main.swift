//
//  main.swift
//  speedball
//
//  Created by 秋星桥 on 5/29/25.
//

import AppKit
import Foundation

#if !DEBUG
    fclose(stdout)
    fclose(stderr)

    Security.removeDebugger()
    guard Security.validateAppSignature() else {
        Security.crashOut()
    }
#endif

_ = CentralProcessorInfo.shared.calculateCurrentLoad()
_ = CentralProcessorInfo.shared.calculateCurrentLoad()
_ = NetworkInfo.shared.updateNetworkUsage()
_ = NetworkInfo.shared.updateNetworkUsage()

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv
)
