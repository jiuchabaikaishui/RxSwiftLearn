//
//  TableViewSectionedDataSource.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/1/8.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SectionModelType {
    associatedtype Item
    
    var items: [Item] { get }
    
    init(original: Self, items: [Item])
}

struct SectionModel<Section, Item> {
    var model: Section
    var items: [Item]
    
    init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }
}

class TableViewSectionedDataSource<Section: SectionModelType>: NSObject, UITableViewDataSource, SectionedViewDataSourceType {
    
    typealias Item = Section.Item
    
    typealias SectionModelSnapshot = SectionModel<Section, Item>
    
    private var _sectionModels: [SectionModelSnapshot] = []
    
    var sectionModels: [Section] { _sectionModels.map({ Section(original: $0.model, items: $0.items) }) }
    
    subscript(section: Int) -> Section {
        let sectionModel = _sectionModels[section]
        
        return Section(original: sectionModel.model, items: sectionModel.items)
    }
    
    subscript(indexPath: IndexPath) -> Item {
        get {
            return _sectionModels[indexPath.section].items[indexPath.row]
        }
        set {
            var section = _sectionModels[indexPath.section]
            section.items[indexPath.row] = newValue
            _sectionModels[indexPath.section] = section
        }
    }
    
    typealias CellForRow = (UITableView, IndexPath) -> UITableViewCell
    
    var cellForRow: CellForRow
    
    init(cellForRow: @escaping CellForRow) {
        self.cellForRow = cellForRow
        
        super.init()
    }
    
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { _sectionModels.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { _sectionModels[section].items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: SectionedViewDataSourceType
    func model(at indexPath: IndexPath) throws -> Any {
        return indexPath
    }
}
