//
//  EditingTableViewViewModel.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/16.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation

enum EditingTableViewCommand {
    case addUsers(users: [User], to: IndexPath)
    case moveUser(from: IndexPath, to: IndexPath)
    case deleteUser(indexPath: IndexPath)
}

struct EditingTabelViewViewModel {
    var sections: [SectionModel<String, User>] = [
        SectionModel<String, User>(model: "Favorite Users", items: [
            User(firstName: "Super", lastName: "Man", imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"),
            User(firstName: "Wat", lastName: "Man", imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF")]),
        SectionModel<String, User>(model: "Normal Users", items: [User]())
    ]
    
    func excuteCommand(command: EditingTableViewCommand) -> EditingTabelViewViewModel {
        switch command {
        case let .addUsers(users, to):
            var sections = self.sections
            sections[to.section].items.insert(contentsOf: users, at: to.row)
            return EditingTabelViewViewModel(sections: sections)
        case let .moveUser(from, to):
            var sections = self.sections
            let user = sections[from.section].items[from.row]
            sections[from.section].items.remove(at: from.row)
            sections[to.section].items.insert(user, at: to.row)
            return EditingTabelViewViewModel(sections: sections)
        case let .deleteUser(indexPath):
            var sections = self.sections
            sections[indexPath.section].items.remove(at: indexPath.row)
            return EditingTabelViewViewModel(sections: sections)
        }
    }
}
