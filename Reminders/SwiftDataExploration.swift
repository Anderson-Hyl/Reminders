//
//  SwiftDataExploration.swift
//  Reminders
//
//  Created by anderson on 2025/6/3.
//

import Foundation
import SwiftData
import SwiftUI

/*var remindersQuery: some SelectStatementOf<Reminder> {
 Reminder
     .where {
         if !showCompleted {
             !$0.isCompleted
         }
     }
     .where {
         switch detailType {
         case .remindersList(let remindersList):
             $0.remindersListID.eq(remindersList.id)
         }
     }
     .order {
         $0.isCompleted
     }
     .order {
         switch ordering {
         case .dueDate:
             $0.dueDate.asc(nulls: .last)
         case .priority:
             ($0.priority.desc(), $0.isFlagged.desc())
         case .title:
             $0.title
         }
     }
}*/

@Model
final class RemindersListModel: Identifiable, Equatable {
    var color = 0x4a_99_ef_ff
    @Relationship
    var reminders: [ReminderModel]
    var title = ""
    
    init(
        color: Int = 0x4a_99_ef_ff,
        reminders: [ReminderModel] = [],
        title: String = ""
    ) {
        self.color = color
        self.reminders = reminders
        self.title = title
    }
}

@Model
final class ReminderModel: Identifiable {
    var dueDate: Date?
    var isCompleted = 0
    var isFlagged = false
    var notes = ""
    var priority: Priority?
    @Relationship(inverse: \RemindersListModel.reminders)
    var remindersList: RemindersListModel
    var title = ""

    enum Priority: Int, Codable {
        case low = 1
        case medium
        case high
    }
    
    init(dueDate: Date? = nil, isCompleted: Int = 0, isFlagged: Bool = false, notes: String = "", priority: Priority? = nil, remindersList: RemindersListModel, title: String = "") {
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.isFlagged = isFlagged
        self.notes = notes
        self.priority = priority
        self.remindersList = remindersList
        self.title = title
    }
}

enum DetailTypeModel {
    case remindersList(RemindersListModel)
}

@MainActor
func remindersQuery(
    showCompleted: Bool,
    detailType: DetailTypeModel,
    ordering: Ordering,
) -> Query<ReminderModel, [ReminderModel]> {
    let detailTypePredicate: Predicate<ReminderModel>
    switch detailType {
    case let .remindersList(remindersList):
        let id = remindersList.id
        detailTypePredicate = #Predicate {
            $0.remindersList.id == id
        }
    }
    return Query(
        filter: #Predicate {
            if !showCompleted {
                $0.isCompleted == 0 && detailTypePredicate.evaluate($0)
            } else {
                detailTypePredicate.evaluate($0)
            }
        },
        sort: [
            SortDescriptor(\.isCompleted)
        ],
        animation: .default
    )
}
