//
//  SectionedDataSource.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/17.
//  Copyright © 2020 QSP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SectionedDataSource<Section: SectionModelType>: NSObject, SectionedViewDataSourceType {
    
    private var _sectionModels: [Section] = []
    
    func setSections(_ sections: [Section]) {
        _sectionModels = sections
    }
    
    func sectionsCount() -> Int {
        return _sectionModels.count
    }
    func itemsCount(section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    subscript(section: Int) -> Section {
        let sectionModel = _sectionModels[section]
        
        return Section(model: sectionModel.model, items: sectionModel.items)
    }
    
    subscript(indexPath: IndexPath) -> Section.Item {
        return _sectionModels[indexPath.section].items[indexPath.row]
    }
    
    // MARK: SectionedViewDataSourceType
    func model(at indexPath: IndexPath) throws -> Any { self[indexPath] }
}
