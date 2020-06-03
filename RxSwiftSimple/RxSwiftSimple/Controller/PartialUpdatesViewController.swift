//
//  PartialUpdatesViewController.swift
//  RxSwiftSimple
//
//  Created by 綦 on 2020/4/6.
//  Copyright © 2020 QSP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PartialUpdatesViewController: ExampleViewController {
    private let cellID = "TextCollectionViewCell"
    private let reusableViewID = "TextCollectionReusableView"
    
    var generator = Randomizer(sections: [NumberSection]())
    var sectionsRelay = BehaviorRelay(value: [NumberSection]())
    
    @IBOutlet weak var partialTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var partialCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 构建UI
        let rightItem = UIBarButtonItem(title: "随机", style: .plain, target: self, action: #selector(rightItemAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightItem
        
        // 构建初始数据
        var sections = [NumberSection]()
        for i in 0 ..< 10 {
            sections.append(NumberSection(model: i + 1, items: Array(i ..< i + 100)))
        }
        generator = Randomizer(sections: sections)
        sectionsRelay.accept(generator.sections)
        
        // 绑定
        let tableViewDataSource = TableViewSectionedDataSource<NumberSection>(cellForRow: { (ds, tv, ip) -> UITableViewCell in
            let cell = CommonCell.cellFor(tableView: tv)
            cell.textLabel?.text = "\(ds[ip])"
            return cell
        }, titleForHeader: { (ds, tv, i) -> String? in
            return "第\(ds[i].model)组"
        })
        sectionsRelay.asObservable().bind(to: partialTableView.rx.items(dataSource: tableViewDataSource)).disposed(by: bag)
        sectionsRelay.asObservable().bind(to: tableView.rx.items(dataSource: tableViewDataSource)).disposed(by: bag)
        Observable.of(tableView.rx.modelSelected(Int.self), partialTableView.rx.modelSelected(Int.self)).merge().subscribe(onNext: {print("我是\($0)") }).disposed(by: bag)
        let collectionViewDataSource = CollectionViewSectionedDataSource<NumberSection>(cellForItem: { [weak self] (ds, cv, ip) -> UICollectionViewCell in
            let cell = TextCollectionViewCell.cellFor(collectionView: cv, indexPath: ip, identifier: self!.cellID)
            cell.textLabel.text = "\(ds[ip])"
            return cell
        }, viewForSupplementaryElement: { [weak self] (ds, cv, kind, ip) -> UICollectionReusableView in
            let view = TextCollectionReusableView.viewFor(collectionView: cv, indexPath: ip, kind: kind, identifier: self!.reusableViewID)
            view.textLabel.text = "第\(ds[ip.section].model)组"
            return view
        })
        sectionsRelay.asObservable().bind(to: partialCollectionView.rx.items(dataSource: collectionViewDataSource)).disposed(by: bag)
        partialCollectionView.rx.modelSelected(Int.self).subscribe(onNext: { print("我是\($0)") }).disposed(by: bag)
    }
    
    @objc func rightItemAction(sender: UIBarButtonItem) {
        generator.randomize()
        sectionsRelay.accept(generator.sections)
    }
}
