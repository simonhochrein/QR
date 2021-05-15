//
//  AppDelegate.swift
//  QR
//
//  Created by Simon Hochrein on 5/15/21.
//

import Cocoa
import SwiftUI

class Focused: ObservableObject {
    @Published var focused: Bool = false
}


@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    var window: NSWindow!
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!
    
    var focused = Focused()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(focused)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)

        self.popover = popover
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "QR")
            button.action = #selector(self.togglePopover(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        statusBarMenu = NSMenu(title: "QR")
        statusBarMenu.delegate = self
        statusBarMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }

    @objc func togglePopover(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            statusBarMenu.popUp(positioning: nil, at: CGPoint(x: -1, y: sender.bounds.maxY + 5), in: sender)
        } else {
            if self.popover.isShown {
               self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.minY)
               self.popover.contentViewController?.view.window?.becomeKey()
               focused.focused = true;
            }
        }
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        focused.focused = false;
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc private func quit() {
        NSApp.terminate(self)
    }

}

