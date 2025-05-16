import SharingGRDB
import SwiftUI

@Observable
class RemindersListsModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database
    @ObservationIgnored
    @FetchAll(RemindersList.order(by: \.title)) var remindersLists
    
    func deleteButtonTapped(at indexSet: IndexSet) {
        withErrorReporting {
            try database.write { db in
                let ids = indexSet.map { remindersLists[$0].id }
                try RemindersList
                    .where { $0.id.in(ids) }
                    .delete()
                    .execute(db)
            }
        }
    }
}

struct RemindersListsView: View {
    let model: RemindersListsModel
    var body: some View {
        List {
            Section {

            }

            Section {
                ForEach(model.remindersLists) { remindersList in
                    RemindersListRow(
                        incompleteRemindersCount: 0,
                        remindersList: remindersList
                    )
                }
                .onDelete { indexSet in
                    model.deleteButtonTapped(at: indexSet)
                }
                
            } header: {
                Text("My lists")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }

            Section {

            } header: {
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
                    Button {

                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Reminder")
                        }
                        .bold()
                        .font(.title3)
                    }
                    Spacer()
                    Button {

                    } label: {
                        Text("Add List")
                            .font(.title3)
                    }
                }
            }
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
