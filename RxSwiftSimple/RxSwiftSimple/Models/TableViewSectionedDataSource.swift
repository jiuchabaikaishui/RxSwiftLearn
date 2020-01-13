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

class TableViewSectionedDataSource<Section: SectionModelType>: NSObject, UITableViewDataSource, SectionedViewDataSourceType, RxTableViewDataSourceType {
    
    typealias Item = Section.Item
    
    typealias SectionModelSnapshot = SectionModel<Section.Section, Item>
    
    private var _sectionModels: [SectionModelSnapshot] = []
    
    subscript(section: Int) -> Section {
        let sectionModel = _sectionModels[section]
        
        return Section(model: sectionModel.model, items: sectionModel.items)
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
    
    typealias CellForRow = (TableViewSectionedDataSource<Section>, UITableView, IndexPath) -> UITableViewCell
    typealias TitleForHeader = (TableViewSectionedDataSource<Section>, UITableView, Int) -> String?
    typealias TitleForFooter = (TableViewSectionedDataSource<Section>, UITableView, Int) -> String?
    typealias CanEditRow = (TableViewSectionedDataSource<Section>, UITableView, IndexPath) -> Bool
    typealias CanMoveRow = (TableViewSectionedDataSource<Section>, UITableView, IndexPath) -> Bool
    
    var cellForRow: CellForRow
    var titleForHeader: TitleForHeader
    var canEditRow: CanEditRow
    var canMoveRow: CanMoveRow
    
    init(cellForRow: @escaping CellForRow, titleForHeader: @escaping TitleForHeader = { _,_,_ in nil }, canEditRow: @escaping CanEditRow = { _,_,_ in false }, canMoveRow: @escaping CanMoveRow = { _,_,_ in false }) {
        self.cellForRow = cellForRow
        self.titleForHeader = titleForHeader
        self.canEditRow = canEditRow
        self.canMoveRow = canMoveRow
        
        super.init()
    }
    
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { _sectionModels.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { _sectionModels[section].items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { cellForRow(self, tableView, indexPath) }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { titleForHeader(self, tableView, section) }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { nil }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { canEditRow(self, tableView, indexPath) }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { canMoveRow(self, tableView, indexPath) }
    
    // MARK: SectionedViewDataSourceType
    func model(at indexPath: IndexPath) throws -> Any { self[indexPath] }
    
    // MArK: RxTableViewDataSourceType
    typealias Element = [Section]
    func tableView(_ tableView: UITableView, observedEvent: Event<TableViewSectionedDataSource<Section>.Element>) {
        Binder(self) { (dataSource, element: Element) in
            self._sectionModels = element.map({ SectionModel(model: $0.model, items: $0.items) })
            tableView.reloadData()
        }.on(observedEvent)
    }
}
