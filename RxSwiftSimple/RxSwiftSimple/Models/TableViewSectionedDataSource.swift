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

class TableViewSectionedDataSource<Section: SectionModelType>: SectionedDataSource<Section>, UITableViewDataSource, RxTableViewDataSourceType {
    
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
    func numberOfSections(in tableView: UITableView) -> Int { sectionsCount() }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { itemsCount(section: section) }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { cellForRow(self, tableView, indexPath) }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { titleForHeader(self, tableView, section) }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { nil }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { canEditRow(self, tableView, indexPath) }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { canMoveRow(self, tableView, indexPath) }
    
    // MArK: RxTableViewDataSourceType
    typealias Element = [Section]
    func tableView(_ tableView: UITableView, observedEvent: Event<TableViewSectionedDataSource<Section>.Element>) {
        Binder(self) { (dataSource, element: Element) in
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
