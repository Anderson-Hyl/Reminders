import SharingGRDB
import SwiftUI

@Observable
@MainActor
class RemindersListsModel {
	@ObservationIgnored
	@Dependency(\.defaultDatabase) var database
	@ObservationIgnored
	@FetchAll(RemindersList.order(by: \.title)) var remindersLists

	@ObservationIgnored
	@FetchAll(
		RemindersList
			.group(by: \.id)
			.order(by: \.title)
			.leftJoin(Reminder.all) {
				$0.id.eq($1.remindersListID) && !$1.isCompleted
			}
			.select {
				RemindersListRow.Columns(
					incompleteRemindersCount: $1.count(),
					remindersList: $0
				)
			},
		animation: .default
	)
	var remindersListRows

	var remindersListForm: RemindersList.Draft?
	
	var remindersDetail: RemindersDetailModel?

	@Selection
	struct RemindersListRow {
		let incompleteRemindersCount: Int
		let remindersList: RemindersList
	}
	
	func deleteButtonTapped(remindersList: RemindersList) {
		withErrorReporting {
			try database.write { db in
				try RemindersList
					.delete(remindersList)
					.execute(db)
			}
		}
	}
	
	func editButtonTapped(remindersList: RemindersList) {
		remindersListForm = RemindersList.Draft(remindersList)
	}
	
	func addListButtonTapped() {
		remindersListForm = RemindersList.Draft()
	}
	
	func remindersDetailTapped(remindersList: RemindersList) {
		remindersDetail = RemindersDetailModel(detailType: .remindersList(remindersList))
	}
}

struct RemindersListsView: View {
	@Bindable var model: RemindersListsModel
	var body: some View {
		List {
			Section {
				ForEach(model.remindersListRows, id: \.remindersList.id) { row in
					Button {
						model.remindersDetailTapped(remindersList: row.remindersList)
					} label: {
						RemindersListRow(
							incompleteRemindersCount: row.incompleteRemindersCount,
							remindersList: row.remindersList
						)
					}
					.buttonStyle(.plain)
					.swipeActions {
						Button(role: .destructive) {
							model.deleteButtonTapped(remindersList: row.remindersList)
						} label: {
							Image(systemName: "trash")
						}
						Button {
							model.editButtonTapped(remindersList: row.remindersList)
						} label: {
							Image(systemName: "info.circle")
						}
					}
				}
			} header: {
				Text("My lists")
					.font(.largeTitle)
					.bold()
					.foregroundStyle(.black)
					.textCase(nil)
			}

			Section {} header: {
				Text("Tags")
					.font(.largeTitle)
					.bold()
					.foregroundStyle(.black)
					.textCase(nil)
			}
		}
		.searchable(text: .constant(""))
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				HStack {
					Button {} label: {
						HStack {
							Image(systemName: "plus.circle.fill")
							Text("New Reminder")
						}
						.bold()
						.font(.title3)
					}
					Spacer()
					Button {
						model.addListButtonTapped()
					} label: {
						Text("Add List")
							.font(.title3)
					}
				}
			}
		}
		.sheet(item: $model.remindersListForm) { form in
			NavigationStack {
				RemindersListForm(remindersList: form)
					.navigationTitle("New List")
			}
			.presentationDetents([.medium])
		}
		.navigationDestination(item: $model.remindersDetail) { reminderDetailModel in
			RemindersDetailView(model: reminderDetailModel)
		}
	}
}

#Preview {
	let _ = prepareDependencies {
		$0.defaultDatabase = try! appDatabase()
	}
	NavigationStack {
		RemindersListsView(model: RemindersListsModel())
	}
}
