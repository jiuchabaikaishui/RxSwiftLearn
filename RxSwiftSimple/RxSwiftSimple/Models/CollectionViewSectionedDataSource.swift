//
//  CollectionViewSectionedDataSource.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/17.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionViewSectionedDataSource<Section: SectionModelType>: SectionedDataSource<Section>, UICollectionViewDataSource, RxCollectionViewDataSourceType {//
    
    typealias CellForItem = (CollectionViewSectionedDataSource<Section>, UICollectionView, IndexPath) -> UICollectionViewCell
    typealias ViewForSupplementaryElement = (CollectionViewSectionedDataSource<Section>, UICollectionView, String,  IndexPath) -> UICollectionReusableView
    typealias CanMoveItem = (CollectionViewSectionedDataSource<Section>, UICollectionView, IndexPath) -> Bool
    typealias MoveItem = (CollectionViewSectionedDataSource<Section>, UICollectionView, IndexPath, IndexPath) -> ()
    
    var cellForItem: CellForItem
    var viewForSupplementaryElement: ViewForSupplementaryElement
    var canMoveItem: CanMoveItem
    var moveItem: MoveItem
    
    init(cellForItem: @escaping CellForItem, viewForSupplementaryElement: @escaping ViewForSupplementaryElement, canMoveItem: @escaping CanMoveItem = { _, _, _ in false }, moveItem: @escaping MoveItem = { _, _, _, _ in }) {
        self.cellForItem = cellForItem
        self.viewForSupplementaryElement = viewForSupplementaryElement
        self.canMoveItem = canMoveItem
        self.moveItem = moveItem
        
        super.init()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionsCount()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsCount(section: section)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cellForItem(self, collectionView, indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        viewForSupplementaryElement(self, collectionView, kind, indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        canMoveItem(self, collectionView, indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveItem(self, collectionView, sourceIndexPath, destinationIndexPath)
    }
    
    // MARK: RxCollectionViewDataSourceType
    typealias Element = [Section]
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<CollectionViewSectionedDataSource<Section>.Element>) {
        Binder(self) { (dataSource, element: Element) in
            dataSource.setSections(element)
            collectionView.reloadData()
        }.on(observedEvent)
    }
}
