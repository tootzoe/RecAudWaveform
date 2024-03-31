//
//  RecAudWaveformApp.swift
//  RecAudWaveform
//
//  Created by thor on 31/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI






#if os(macOS)

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif



@main
struct RecAudWaveformApp: App {
    
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDeleg
 #endif
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
