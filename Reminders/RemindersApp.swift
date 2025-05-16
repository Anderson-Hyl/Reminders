//
//  RemindersApp.swift
//  Reminders
//
//  Created by anderson on 2025/5/16.
//

import SwiftUI

@main
struct RemindersApp: App {
    init() {
        let _ = try! appDatabase()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
