//
//  RemindersApp.swift
//  Reminders
//
//  Created by anderson on 2025/5/16.
//
import SwiftUI
import Dependencies

@main
struct RemindersApp: App {
	@State var remindersListsModel = RemindersListsModel()
	init() {
		prepareDependencies {
			$0.defaultDatabase = try! appDatabase()
		}
	}
	var body: some Scene {
		WindowGroup {
			RemindersListsView(model: remindersListsModel)
		}
	}
}
