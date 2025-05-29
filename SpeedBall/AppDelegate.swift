//
//  AppDelegate.swift
//  SpeedBall
//
//  Created by 秋星桥 on 5/29/25.
//

import AppKit
import SkyLightWindow
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()

        #if DEBUG
            if let debug = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"],
               !debug.isEmpty
            {
                print("[*] SwiftUI Preview Detected")
                return
            }
        #endif

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recreateWindow),
            name: NSWindow.didChangeScreenNotification,
            object: nil
        )

        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            NSApp.setActivationPolicy(.accessory)
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    var controller: NSWindowController?
    @objc func recreateWindow() {
        controller?.close()
        controller = nil
        guard let main = NSScreen.main else { return }
        controller = SkyLightOperator.shared.delegateView(
            .init(BallContainerView()),
            toScreen: main
        )
    }

    func applicationDidFinishLaunching(_: Notification) {
        if controller == nil { recreateWindow() }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
