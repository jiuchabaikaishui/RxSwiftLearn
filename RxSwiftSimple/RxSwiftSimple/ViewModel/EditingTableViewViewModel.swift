//
//  EditingTableViewViewModel.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/16.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum EditingTableViewCommand {
    case addUsers(users: [User], to: IndexPath)
    case moveUser(from: IndexPath, to: IndexPath)
    case deleteUser(indexPath: IndexPath)
}

struct EditingTabelViewViewModel {
    static let initalSections: [SectionModel<String, User>] = [
        SectionModel<String, User>(model: "Favorite Users", items: [
            User(firstName: "Super", lastName: "Man", imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"),
            User(firstName: "Wat", lastName: "Man", imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF")]),
        SectionModel<String, User>(model: "Normal Users", items: [User]())
    ]
    private let activity = ActivityIndicator()
    
    let sections: Driver<[SectionModel<String, User>]>
    let loading: Driver<Bool>
    
    static func excuteCommand(sections: [SectionModel<String, User>], command: EditingTableViewCommand) -> [SectionModel<String, User>] {
        var result = sections
        switch command {
        case let .addUsers(users, to):
            result[to.section].items.insert(contentsOf: users, at: to.row)
        case let .moveUser(from, to):
            let user = sections[from.section].items[from.row]
            result[from.section].items.remove(at: from.row)
            result[to.section].items.insert(user, at: to.row)
        case let .deleteUser(indexPath):
            result[indexPath.section].items.remove(at: indexPath.row)
        }
        return result
    }
    
    init(itemDelete: RxCocoa.ControlEvent<IndexPath>, itemMoved: RxCocoa.ControlEvent<RxCocoa.ItemMovedEvent>) {
        self.loading = activity.asDriver(onErrorJustReturn: false)
        let add = UserAPI.getUsers(count: 30)
            .map { EditingTableViewCommand.addUsers(users: $0, to: IndexPath(row: 0, section: 1)) }
            .trackActivity(activity)
        
        sections = Observable.deferred {
            let delete = itemDelete.map { EditingTableViewCommand.deleteUser(indexPath: $0) }
            let move = itemMoved.map(EditingTableViewCommand.moveUser)
            return Observable.merge(add, delete, move)
                .scan(EditingTabelViewViewModel.initalSections, accumulator: EditingTabelViewViewModel.excuteCommand(sections:command:))
        }.startWith(EditingTabelViewViewModel.initalSections)
        .asDriver(onErrorJustReturn: EditingTabelViewViewModel.initalSections)
    }
}
