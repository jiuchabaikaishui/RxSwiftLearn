//
//  SectionModel.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/17.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation

protocol SectionModelType {
    associatedtype Section
    associatedtype Item
    
    var model: Section { get }
    var items: [Item] { get }
    
    init(model: Section, items: [Item])
}

struct SectionModel<SectionType, ItemType>: SectionModelType {
    typealias Section = SectionType
    typealias Item = ItemType
    
    var model: Section
    var items: [Item]
    
    init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }
}
